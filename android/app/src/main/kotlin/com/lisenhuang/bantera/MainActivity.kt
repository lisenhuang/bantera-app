package com.lisenhuang.bantera

import android.content.Context
import android.content.Intent
import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
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
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException
import java.nio.ByteBuffer
import java.nio.ByteOrder

private const val SPEECH_TAG = "BanteraSpeech"
private const val TARGET_RATE = 16000

/**
 * Android side of the `bantera/video_processing` MethodChannel.
 *
 * Mirrors the iOS practice-page transcription: transcribes an audio FILE on-device.
 * Android's built-in [SpeechRecognizer] reads a file (instead of the live mic) via
 * [RecognizerIntent.EXTRA_AUDIO_SOURCE] + [RecognizerIntent.EXTRA_SEGMENTED_SESSION]
 * on Android 13+ (API 33). The file is first decoded to 16 kHz mono 16-bit PCM, so this
 * handles both practice WAV recordings and chat voice messages (AAC/m4a).
 * No cloud API of ours and no bundled ASR model — this is the system recognizer.
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
 * Decodes one audio file to 16 kHz mono PCM, runs a single file-based recognition session,
 * and replies on the channel exactly once. Created only on API 33+.
 */
@RequiresApi(Build.VERSION_CODES.TIRAMISU)
private class RecordedAudioTranscriber(private val context: Context) {
    private val mainHandler = Handler(Looper.getMainLooper())
    @Volatile private var recognizer: SpeechRecognizer? = null
    @Volatile private var pfd: ParcelFileDescriptor? = null
    @Volatile private var pcmFile: File? = null
    private val segmentedText = StringBuilder()
    private var replied = false // only touched on the main thread

    fun transcribe(input: File, rawLocale: String, result: MethodChannel.Result) {
        val localeIdentifier = normalizeLocale(rawLocale)
        // Decode off the main thread — chat voice messages can be long enough to ANR.
        Thread {
            val pcm: File
            try {
                pcm = decodeToMono16kPcm(input)
            } catch (e: Exception) {
                Log.e(SPEECH_TAG, "decode failed for ${input.path}", e)
                mainHandler.post {
                    replyError(result, "invalid_recording", "The recording could not be read for transcription.")
                }
                return@Thread
            }
            pcmFile = pcm
            Log.i(SPEECH_TAG, "transcribe: locale=$localeIdentifier src=${input.length()}B pcm=${pcm.length()}B")

            val descriptor: ParcelFileDescriptor
            try {
                descriptor = ParcelFileDescriptor.open(pcm, ParcelFileDescriptor.MODE_READ_ONLY)
            } catch (e: Exception) {
                Log.e(SPEECH_TAG, "open PFD failed", e)
                mainHandler.post {
                    replyError(result, "invalid_recording", "The recording could not be opened for transcription.")
                }
                return@Thread
            }
            pfd = descriptor

            // Feed the decoded file to the recognizer instead of the live mic. The audio-source
            // extras MUST match the decoded format: 16 kHz, mono, 16-bit PCM. EXTRA_SEGMENTED_SESSION
            // is required so Google's recognizer consumes the file and reports via onSegmentResults().
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, localeIdentifier)
                putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, context.packageName)
                putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, false)
                putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE, descriptor)
                putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_CHANNEL_COUNT, 1)
                putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_ENCODING, AudioFormat.ENCODING_PCM_16BIT)
                putExtra(RecognizerIntent.EXTRA_AUDIO_SOURCE_SAMPLING_RATE, TARGET_RATE)
                putExtra(RecognizerIntent.EXTRA_SEGMENTED_SESSION, RecognizerIntent.EXTRA_AUDIO_SOURCE)
            }

            mainHandler.post {
                if (replied) {
                    cleanup()
                    return@post
                }
                val sr = SpeechRecognizer.createSpeechRecognizer(context)
                recognizer = sr
                sr.setRecognitionListener(object : RecognitionListener {
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

                    // Fallback for recognizers that ignore segmented mode.
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
        }.start()
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

    /** Decodes any supported audio file to 16 kHz mono 16-bit PCM and writes a temp .pcm file. */
    private fun decodeToMono16kPcm(input: File): File {
        val (pcm16, srcRate, channels) = readSourcePcm(input)
        val converted = downmixAndResample(pcm16, srcRate, channels)
        Log.i(SPEECH_TAG, "decoded: srcRate=$srcRate ch=$channels -> 16k mono ${converted.size}B")
        val out = File.createTempFile("bantera_pcm_", ".pcm", context.cacheDir)
        out.outputStream().use { it.write(converted) }
        return out
    }

    /** Returns (16-bit PCM bytes, sampleRate, channelCount). WAV via header parse, else MediaCodec. */
    private fun readSourcePcm(input: File): Triple<ByteArray, Int, Int> {
        val head = ByteArray(12)
        input.inputStream().use { it.read(head) }
        val isWav = String(head, 0, 4, Charsets.US_ASCII) == "RIFF" &&
            String(head, 8, 4, Charsets.US_ASCII) == "WAVE"
        return if (isWav) readWavPcm(input) else decodeCompressed(input)
    }

    private fun readWavPcm(wav: File): Triple<ByteArray, Int, Int> {
        val bytes = wav.readBytes()
        var channels = 1
        var sampleRate = TARGET_RATE
        var bits = 16
        var dataOffset = -1
        var dataSize = 0
        var i = 12
        while (i + 8 <= bytes.size) {
            val id = String(bytes, i, 4, Charsets.US_ASCII)
            val size = le32(bytes, i + 4)
            val body = i + 8
            if (id == "fmt " && body + 16 <= bytes.size) {
                channels = le16(bytes, body + 2)
                sampleRate = le32(bytes, body + 4)
                bits = le16(bytes, body + 14)
            } else if (id == "data") {
                dataOffset = body
                dataSize = size.coerceAtMost(bytes.size - body)
                break
            }
            if (size <= 0) break
            i = body + size + (size and 1) // chunks are word-aligned
        }
        if (dataOffset < 0) {
            dataOffset = minOf(44, bytes.size)
            dataSize = bytes.size - dataOffset
        }
        if (bits != 16) throw IOException("unsupported WAV bit depth $bits")
        return Triple(bytes.copyOfRange(dataOffset, dataOffset + dataSize), sampleRate, channels)
    }

    private fun decodeCompressed(input: File): Triple<ByteArray, Int, Int> {
        val extractor = MediaExtractor()
        extractor.setDataSource(input.path)
        var trackIndex = -1
        var format: MediaFormat? = null
        for (t in 0 until extractor.trackCount) {
            val f = extractor.getTrackFormat(t)
            if (f.getString(MediaFormat.KEY_MIME)?.startsWith("audio/") == true) {
                trackIndex = t
                format = f
                break
            }
        }
        if (trackIndex < 0 || format == null) {
            extractor.release()
            throw IOException("no audio track")
        }
        extractor.selectTrack(trackIndex)
        var sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        var channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        val codec = MediaCodec.createDecoderByType(format.getString(MediaFormat.KEY_MIME)!!)
        codec.configure(format, null, null, 0)
        codec.start()

        val out = ByteArrayOutputStream()
        val info = MediaCodec.BufferInfo()
        var sawInputEos = false
        var sawOutputEos = false
        try {
            while (!sawOutputEos) {
                if (!sawInputEos) {
                    val inIndex = codec.dequeueInputBuffer(10_000)
                    if (inIndex >= 0) {
                        val inBuf = codec.getInputBuffer(inIndex)!!
                        val sampleSize = extractor.readSampleData(inBuf, 0)
                        if (sampleSize < 0) {
                            codec.queueInputBuffer(inIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            sawInputEos = true
                        } else {
                            codec.queueInputBuffer(inIndex, 0, sampleSize, extractor.sampleTime, 0)
                            extractor.advance()
                        }
                    }
                }
                val outIndex = codec.dequeueOutputBuffer(info, 10_000)
                if (outIndex >= 0) {
                    val outBuf = codec.getOutputBuffer(outIndex)!!
                    if (info.size > 0) {
                        val chunk = ByteArray(info.size)
                        outBuf.get(chunk)
                        out.write(chunk)
                    }
                    outBuf.clear()
                    codec.releaseOutputBuffer(outIndex, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) sawOutputEos = true
                } else if (outIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    val of = codec.outputFormat
                    sampleRate = of.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                    channels = of.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                }
            }
        } finally {
            try { codec.stop() } catch (_: Exception) {}
            codec.release()
            extractor.release()
        }
        return Triple(out.toByteArray(), sampleRate, channels)
    }

    /** Downmixes to mono and linearly resamples 16-bit PCM to 16 kHz. */
    private fun downmixAndResample(pcm: ByteArray, srcRate: Int, channels: Int): ByteArray {
        val total = pcm.size / 2
        if (total == 0) return ByteArray(0)
        val samples = ShortArray(total)
        ByteBuffer.wrap(pcm).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer().get(samples)

        val mono: ShortArray = if (channels <= 1) {
            samples
        } else {
            val frames = total / channels
            ShortArray(frames) { f ->
                var sum = 0
                for (c in 0 until channels) sum += samples[f * channels + c]
                (sum / channels).toShort()
            }
        }

        val resampled: ShortArray = if (srcRate == TARGET_RATE || mono.isEmpty()) {
            mono
        } else {
            val outLen = (mono.size.toLong() * TARGET_RATE / srcRate).toInt().coerceAtLeast(1)
            ShortArray(outLen) { i ->
                val srcPos = i.toDouble() * srcRate / TARGET_RATE
                val idx = srcPos.toInt()
                val frac = srcPos - idx
                val a = mono[idx.coerceIn(0, mono.size - 1)].toInt()
                val b = mono[(idx + 1).coerceIn(0, mono.size - 1)].toInt()
                (a + (b - a) * frac).toInt().toShort()
            }
        }

        val outBytes = ByteArray(resampled.size * 2)
        ByteBuffer.wrap(outBytes).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer().put(resampled)
        return outBytes
    }

    private fun le16(b: ByteArray, o: Int) =
        (b[o].toInt() and 0xff) or ((b[o + 1].toInt() and 0xff) shl 8)

    private fun le32(b: ByteArray, o: Int) =
        (b[o].toInt() and 0xff) or ((b[o + 1].toInt() and 0xff) shl 8) or
            ((b[o + 2].toInt() and 0xff) shl 16) or ((b[o + 3].toInt() and 0xff) shl 24)

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
