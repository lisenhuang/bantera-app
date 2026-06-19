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
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

private const val SPEECH_TAG = "BanteraSpeech"

/**
 * Android side of the `bantera/video_processing` MethodChannel.
 *
 * Mirrors the iOS practice-page transcription: the app records a 16 kHz mono PCM WAV and
 * asks us to transcribe that FILE. Android's built-in [SpeechRecognizer] can read a file
 * (instead of the live mic) via [RecognizerIntent.EXTRA_AUDIO_SOURCE] on Android 13+ (API 33).
 * No cloud API of ours and no bundled ASR model — this is the system recognizer.
 *
 * Only the practice-path methods are implemented; video-upload transcription stays iOS-only.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "bantera/video_processing"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "ensureRecordedAudioTranscriptionReady" -> handleEnsureReady(result)
                    "transcribeRecordedAudio" -> handleTranscribe(
                        call.argument<String>("inputPath"),
                        call.argument<String>("localeIdentifier"),
                        result,
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun handleEnsureReady(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.error("needs_android_13", "Speaking practice needs Android 13 or newer.", null)
            return
        }
        val available = SpeechRecognizer.isRecognitionAvailable(this)
        Log.i(SPEECH_TAG, "ensureReady: sdk=${Build.VERSION.SDK_INT} recognitionAvailable=$available")
        if (!available) {
            result.error(
                "speech_unavailable",
                "Speech recognition isn’t available on this device.",
                null,
            )
            return
        }
        result.success(null)
    }

    private fun handleTranscribe(
        inputPath: String?,
        localeIdentifier: String?,
        result: MethodChannel.Result,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.error("needs_android_13", "Speaking practice needs Android 13 or newer.", null)
            return
        }
        if (inputPath.isNullOrEmpty()) {
            result.error("missing_recording", "Bantera could not access the recorded audio.", null)
            return
        }
        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            result.error(
                "speech_unavailable",
                "Speech recognition isn’t available on this device.",
                null,
            )
            return
        }
        RecordedAudioTranscriber(applicationContext)
            .transcribe(File(inputPath), localeIdentifier ?: "en-US", result)
    }
}

/**
 * Runs one file-based recognition session and replies on the channel exactly once.
 * Created only on API 33+ (callers guard on [Build.VERSION_CODES.TIRAMISU]).
 */
@RequiresApi(Build.VERSION_CODES.TIRAMISU)
private class RecordedAudioTranscriber(private val context: Context) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var recognizer: SpeechRecognizer? = null
    private var pfd: ParcelFileDescriptor? = null
    private var pcmFile: File? = null
    private var replied = false

    private val segmentedText = StringBuilder()

    fun transcribe(wavFile: File, rawLocale: String, result: MethodChannel.Result) {
        val localeIdentifier = normalizeLocale(rawLocale)
        val pcm: File
        try {
            pcm = extractPcm(wavFile)
        } catch (e: Exception) {
            Log.e(SPEECH_TAG, "extractPcm failed for ${wavFile.path}", e)
            result.error("invalid_recording", "The recording could not be read for transcription.", null)
            return
        }
        pcmFile = pcm
        Log.i(
            SPEECH_TAG,
            "transcribe: locale=$localeIdentifier wav=${wavFile.length()}B pcm=${pcm.length()}B",
        )

        val descriptor: ParcelFileDescriptor
        try {
            descriptor = ParcelFileDescriptor.open(pcm, ParcelFileDescriptor.MODE_READ_ONLY)
        } catch (e: Exception) {
            Log.e(SPEECH_TAG, "open PFD failed", e)
            cleanup()
            result.error("invalid_recording", "The recording could not be opened for transcription.", null)
            return
        }
        pfd = descriptor

        // Feed the recorded file to the recognizer instead of the live mic. The audio-source
        // extras MUST match how the WAV was recorded: 16 kHz, mono, 16-bit PCM.
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, localeIdentifier)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, context.packageName)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, false)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE, descriptor)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_CHANNEL_COUNT, 1)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_ENCODING, AudioFormat.ENCODING_PCM_16BIT)
            putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_SAMPLING_RATE, 16000)
            // Required for file-based recognition: Google's recognizer consumes the audio
            // source as a segmented session and returns text via onSegmentResults().
            putExtra(RecognizerIntent.EXTRA_SEGMENTED_SESSION, RecognizerIntent.EXTRA_AUDIO_SOURCE)
        }

        mainHandler.post {
            val sr = SpeechRecognizer.createSpeechRecognizer(context)
            recognizer = sr
            sr.setRecognitionListener(object : RecognitionListener {
                override fun onResults(results: Bundle?) {
                    val text = results
                        ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                        ?.firstOrNull()
                        ?.trim()
                        .orEmpty()
                    Log.i(SPEECH_TAG, "onResults: \"$text\"")
                    replySuccess(result, text, localeIdentifier)
                }

                override fun onError(error: Int) {
                    Log.w(SPEECH_TAG, "onError: code=$error (${errorName(error)})")
                    // No speech detected → return an empty transcript so the Dart pipeline
                    // surfaces the friendly "try again closer to the mic" message.
                    if (error == SpeechRecognizer.ERROR_NO_MATCH ||
                        error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT
                    ) {
                        replySuccess(result, "", localeIdentifier)
                        return
                    }
                    replyError(result, "speech_error_$error", errorMessage(error))
                }

                // File-based recognition returns results here (segmented session),
                // not via onResults(). Accumulate each segment.
                override fun onSegmentResults(segmentResults: Bundle) {
                    val part = segmentResults
                        .getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                        ?.firstOrNull()
                        ?.trim()
                        .orEmpty()
                    Log.i(SPEECH_TAG, "onSegmentResults: \"$part\"")
                    if (part.isNotEmpty()) {
                        if (segmentedText.isNotEmpty()) segmentedText.append(' ')
                        segmentedText.append(part)
                    }
                }

                override fun onEndOfSegmentedSession() {
                    val text = segmentedText.toString().trim()
                    Log.i(SPEECH_TAG, "onEndOfSegmentedSession: \"$text\"")
                    replySuccess(result, text, localeIdentifier)
                }

                override fun onReadyForSpeech(params: Bundle?) {}
                override fun onBeginningOfSpeech() {}
                override fun onRmsChanged(rmsdB: Float) {}
                override fun onBufferReceived(buffer: ByteArray?) {}
                override fun onEndOfSpeech() {}
                override fun onPartialResults(partialResults: Bundle?) {}
                override fun onEvent(eventType: Int, params: Bundle?) {}
            })
            try {
                sr.startListening(intent)
            } catch (e: Exception) {
                Log.e(SPEECH_TAG, "startListening threw", e)
                replyError(result, "speech_start_failed", "Speech recognition could not start.")
            }
        }
    }

    private fun replySuccess(result: MethodChannel.Result, text: String, locale: String) {
        if (replied) return
        replied = true
        result.success(
            mapOf(
                "transcriptText" to text,
                "transcriptLanguage" to locale,
                // Per-word confidence/timing isn't reliably exposed here; text-level
                // comparison still works. Left empty rather than faking confidences.
                "segments" to emptyList<Map<String, Any>>(),
                "recognitionMode" to "unknown",
            ),
        )
        cleanup()
    }

    private fun replyError(result: MethodChannel.Result, code: String, message: String) {
        if (replied) return
        replied = true
        result.error(code, message, null)
        cleanup()
    }

    private fun cleanup() {
        mainHandler.post {
            try { recognizer?.destroy() } catch (_: Exception) {}
            recognizer = null
        }
        try { pfd?.close() } catch (_: Exception) {}
        pfd = null
        try { pcmFile?.delete() } catch (_: Exception) {}
        pcmFile = null
    }

    /** Copies the raw 16-bit PCM samples out of a WAV container into a headerless temp file. */
    private fun extractPcm(wav: File): File {
        val bytes = wav.readBytes()
        var dataOffset = 44 // standard PCM WAV header; fallback if no chunk found
        var i = 12
        while (i + 8 <= bytes.size) {
            val id = String(bytes, i, 4, Charsets.US_ASCII)
            val size = (bytes[i + 4].toInt() and 0xff) or
                ((bytes[i + 5].toInt() and 0xff) shl 8) or
                ((bytes[i + 6].toInt() and 0xff) shl 16) or
                ((bytes[i + 7].toInt() and 0xff) shl 24)
            if (id == "data") {
                dataOffset = i + 8
                break
            }
            i += 8 + size
        }
        if (dataOffset >= bytes.size) dataOffset = minOf(44, bytes.size)
        val out = File.createTempFile("bantera_pcm_", ".pcm", context.cacheDir)
        out.outputStream().use { it.write(bytes, dataOffset, bytes.size - dataOffset) }
        return out
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
