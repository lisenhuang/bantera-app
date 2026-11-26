package com.lisenhuang.bantera

import android.content.Context
import android.content.Intent
import android.media.AudioFormat
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.nio.ByteBuffer
import kotlin.concurrent.thread

internal const val SPEECH_TAG = "BanteraSpeech"
private const val TARGET_RATE = 16000

/** One file-based recognition attempt. Session state and channel replies belong to the main thread. */
@RequiresApi(Build.VERSION_CODES.TIRAMISU)
internal class RecordedAudioTranscriber(
    private val context: Context,
    rawLocale: String,
    private val result: MethodChannel.Result,
) : RecognitionListener {
    private val locale = normalizeLocale(rawLocale)
    private val main = Handler(Looper.getMainLooper())
    private var recognizer: SpeechRecognizer? = null
    private var source: ParcelFileDescriptor? = null
    private var writer: Thread? = null
    private val segments = mutableListOf<String>()
    private var finished = false
    private val timeout = Runnable {
        Log.w(SPEECH_TAG, "Recorded speech timed out")
        if (segments.isEmpty()) {
            fail("speech_timeout", "Speech recognition timed out. Please try again.")
        } else {
            succeed(segments.joinToString(" "))
        }
    }

    fun transcribe(input: File) {
        main.postDelayed(timeout, 120_000L) // Match the shared decoder's upper bound.
        thread(name = "Bantera speech decode") {
            try {
                val (pcm, rate, channels) = LocalAudioDecoder.readSourcePcm(input)
                val audio = LocalAudioDecoder.downmixAndResample(pcm, rate, channels)
                main.post { recognise(audio) }
            } catch (error: Exception) {
                Log.w(SPEECH_TAG, "Could not decode recording", error)
                main.post { fail("invalid_recording", "The recording could not be read for transcription.") }
            }
        }
    }

    internal fun recognise(pcm: ByteArray) {
        if (finished) return
        main.removeCallbacks(timeout)
        // Allow real-time consumption of long chat messages plus service startup/finalisation.
        main.postDelayed(timeout, 15_000L + pcm.size * 1000L / (2 * TARGET_RATE))
        try {
            val (readEnd, writeEnd) = ParcelFileDescriptor.createPipe()
            source = readEnd
            // Closing the writer signals EOF independently of any recognizer callback.
            // FileChannel writes are interruptible if a provider stops reading a full pipe.
            writer = thread(name = "Bantera speech input") {
                try {
                    ParcelFileDescriptor.AutoCloseOutputStream(writeEnd).use { output ->
                        val buffer = ByteBuffer.wrap(pcm)
                        while (buffer.hasRemaining()) output.channel.write(buffer)
                    }
                } catch (error: IOException) {
                    main.post {
                        if (!finished) {
                            Log.w(SPEECH_TAG, "Could not feed speech input", error)
                            fail("invalid_recording", "The recording could not be read for transcription.")
                        }
                    }
                }
            }
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, locale)
                putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, context.packageName)
                putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, false)
                putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE, readEnd)
                putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_CHANNEL_COUNT, 1)
                putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_ENCODING, AudioFormat.ENCODING_PCM_16BIT)
                putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_SAMPLING_RATE, TARGET_RATE)
                putExtra(RecognizerIntent.EXTRA_SEGMENTED_SESSION, RecognizerIntent.EXTRA_AUDIO_SOURCE)
            }
            val sr = SpeechRecognizer.createSpeechRecognizer(context)
            recognizer = sr
            sr.setRecognitionListener(this)
            sr.startListening(intent)
        } catch (error: Exception) {
            Log.w(SPEECH_TAG, "Could not start recorded speech recognition", error)
            fail("speech_start_failed", "Speech recognition could not start.")
        }
    }

    private fun text(bundle: Bundle?) =
        bundle?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull()?.trim().orEmpty()

    override fun onSegmentResults(segmentResults: Bundle) {
        if (finished) return
        val segment = text(segmentResults)
        if (segment.isNotEmpty()) segments.add(segment)
    }

    override fun onEndOfSegmentedSession() = succeed(segments.joinToString(" "))

    override fun onResults(results: Bundle?) = succeed(text(results).ifEmpty { segments.joinToString(" ") })

    override fun onError(error: Int) {
        Log.w(SPEECH_TAG, "onError: code=$error (${errorName(error)})")
        if (error == SpeechRecognizer.ERROR_NO_MATCH || error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT) {
            succeed(segments.joinToString(" "))
        } else {
            fail("speech_error_$error", errorMessage(error))
        }
    }

    override fun onReadyForSpeech(params: Bundle?) {}
    override fun onBeginningOfSpeech() {}
    override fun onRmsChanged(rmsdB: Float) {}
    override fun onBufferReceived(buffer: ByteArray?) {}
    override fun onEndOfSpeech() {}
    override fun onPartialResults(partialResults: Bundle?) {}
    override fun onEvent(eventType: Int, params: Bundle?) {}

    private fun succeed(text: String) = finish {
        result.success(mapOf(
            "transcriptText" to text,
            "transcriptLanguage" to locale,
            "segments" to emptyList<Map<String, Any>>(),
            "recognitionMode" to "unknown",
        ))
    }

    private fun fail(code: String, message: String) = finish { result.error(code, message, null) }

    private fun finish(reply: () -> Unit) {
        if (finished) return
        finished = true
        main.removeCallbacks(timeout)
        try { source?.close() } catch (_: IOException) {}
        writer?.interrupt()
        try { recognizer?.destroy() } catch (_: RuntimeException) {}
        reply()
    }

    /** Normalizes e.g. "en-us"/"en_US" → "en-US" so the recognizer matches a language. */
    private fun normalizeLocale(raw: String): String {
        val parts = raw.trim().replace('_', '-').split('-')
        return if (parts.size >= 2 && parts[1].isNotEmpty()) {
            "${parts[0].lowercase()}-${parts[1].uppercase()}"
        } else {
            parts[0].lowercase()
        }
    }

    private fun errorMessage(error: Int): String = when (error) {
        SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS ->
            "Microphone permission is required for speech recognition. (code $error)"
        SpeechRecognizer.ERROR_LANGUAGE_NOT_SUPPORTED,
        SpeechRecognizer.ERROR_LANGUAGE_UNAVAILABLE ->
            "This language isn’t available for transcription on this device yet. (code $error)"
        else -> "Speech recognition failed (code $error: ${errorName(error)})."
    }

    private fun errorName(error: Int): String = when (error) {
        SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "NETWORK_TIMEOUT"
        SpeechRecognizer.ERROR_NETWORK -> "NETWORK"
        SpeechRecognizer.ERROR_AUDIO -> "AUDIO"
        SpeechRecognizer.ERROR_SERVER -> "SERVER"
        SpeechRecognizer.ERROR_CLIENT -> "CLIENT"
        SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "SPEECH_TIMEOUT"
        SpeechRecognizer.ERROR_NO_MATCH -> "NO_MATCH"
        SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "RECOGNIZER_BUSY"
        SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "INSUFFICIENT_PERMISSIONS"
        SpeechRecognizer.ERROR_TOO_MANY_REQUESTS -> "TOO_MANY_REQUESTS"
        SpeechRecognizer.ERROR_SERVER_DISCONNECTED -> "SERVER_DISCONNECTED"
        SpeechRecognizer.ERROR_LANGUAGE_NOT_SUPPORTED -> "LANGUAGE_NOT_SUPPORTED"
        SpeechRecognizer.ERROR_LANGUAGE_UNAVAILABLE -> "LANGUAGE_UNAVAILABLE"
        SpeechRecognizer.ERROR_CANNOT_CHECK_SUPPORT -> "CANNOT_CHECK_SUPPORT"
        else -> "UNKNOWN"
    }
}
