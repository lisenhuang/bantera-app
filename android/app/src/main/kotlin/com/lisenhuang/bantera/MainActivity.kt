package com.lisenhuang.bantera

import android.os.Build
import android.os.Handler
import android.os.Looper
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import com.google.android.gms.tasks.Tasks
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.install.model.UpdateAvailability
import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModelManager
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.TranslateRemoteModel
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.TranslatorOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.util.Locale

private const val TRANSLATE_TAG = "BanteraTranslate"

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
    private val voiceDecodeWorker = java.util.concurrent.Executors.newSingleThreadExecutor()
    private val localAudioWorker = java.util.concurrent.Executors.newSingleThreadExecutor()
    private var aiAudioBridge: BanteraAiAudioBridge? = null
    private var waveformBridge: AudioWaveformBridge? = null

    override fun onDestroy() { voiceDecodeWorker.shutdown(); localAudioWorker.shutdown(); waveformBridge?.dispose(); aiAudioBridge?.dispose(); super.onDestroy() }

    private var photoSaveBridge: PhotoSaveBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bantera/local_audio_storage")
            .setMethodCallHandler { call, result ->
                val path = call.argument<String>("input")
                if (path == null) { result.error("invalid_audio", "Missing audio.", null); return@setMethodCallHandler }
                val worker = if (call.method == "decodeVoice") voiceDecodeWorker else localAudioWorker
                worker.execute {
                    try {
                        val file = File(path)
                        // Bound memory on devices with small heaps. Large files stay WAV.
                        require(file.length() in 1..(64L * 1024 * 1024))
                        val value: Any = when (call.method) {
                            "compress" -> {
                                require(file.extension.lowercase() == "wav")
                                val output = File(requireNotNull(call.argument<String>("output")))
                                val (pcm, rate, channels) = LocalAudioDecoder.readSourcePcm(file)
                                LocalAudioEncoder.encode(pcm, rate, channels, output)
                                val (decoded, decodedRate, decodedChannels) = LocalAudioDecoder.readSourcePcm(output)
                                val seconds = pcm.size.toDouble() / (rate * channels * 2)
                                val actual = decoded.size.toDouble() / (decodedRate * decodedChannels * 2)
                                require(channels == decodedChannels && decoded.isNotEmpty() &&
                                    kotlin.math.abs(seconds - actual) <= maxOf(0.15, seconds * 0.01))
                                true
                            }
                            "decodeVoice" -> {
                                val (pcm, rate, channels) = LocalAudioDecoder.readSourcePcm(file)
                                LocalAudioDecoder.downmixAndResample(pcm, rate, channels)
                            }
                            else -> throw IOException("Unsupported audio operation")
                        }
                        runOnUiThread { result.success(value) }
                    } catch (_: Exception) {
                        runOnUiThread { result.error("audio_conversion_failed", "Could not convert audio.", null) }
                    }
                }
            }
        waveformBridge = AudioWaveformBridge(flutterEngine.dartExecutor.binaryMessenger)
        aiAudioBridge = BanteraAiAudioBridge(this, flutterEngine.dartExecutor.binaryMessenger)
        photoSaveBridge = PhotoSaveBridge(this, flutterEngine.dartExecutor.binaryMessenger)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bantera/word_boundaries")
            .setMethodCallHandler { call, result ->
                if (call.method != "tokenize") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val text = call.argument<String>("text")
                val tag = call.argument<String>("locale")
                if (text == null || tag == null || text.length > 16000) {
                    result.error("invalid_text", "Invalid sentence.", null)
                    return@setMethodCallHandler
                }
                val locale = Locale.forLanguageTag(tag.replace('_', '-'))
                val iterator = android.icu.text.BreakIterator.getWordInstance(locale)
                iterator.setText(text)
                val words = mutableListOf<Map<String, Int>>()
                var start = iterator.first()
                var end = iterator.next()
                while (end != android.icu.text.BreakIterator.DONE) {
                    if (text.substring(start, end).codePoints().anyMatch { Character.isLetterOrDigit(it) }) {
                        words.add(mapOf("start" to start, "end" to end))
                    }
                    start = end
                    end = iterator.next()
                }
                result.success(words)
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bantera/app_updates")
            .setMethodCallHandler { call, result ->
                if (call.method != "checkForUpdate") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                // Play determines availability for this account, device and release track.
                // Unknown/unavailable checks must not be reported as "up to date".
                AppUpdateManagerFactory.create(applicationContext).appUpdateInfo
                    .addOnSuccessListener { info ->
                        val needsUpdate = when (info.updateAvailability()) {
                            UpdateAvailability.UPDATE_AVAILABLE,
                            UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS -> true
                            UpdateAvailability.UPDATE_NOT_AVAILABLE -> false
                            else -> null
                        }
                        result.success(needsUpdate)
                    }
                    .addOnFailureListener {
                        result.error("play_update_unavailable", "Could not check Google Play for updates.", null)
                    }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "supportsPracticeTranscription" -> result.success(
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                            SpeechRecognizer.isRecognitionAvailable(this),
                    )
                    "ensureRecordedAudioTranscriptionReady" -> handleEnsureReady(result)
                    "transcribeRecordedAudio" -> handleTranscribe(
                        call.argument<String>("inputPath"),
                        call.argument<String>("localeIdentifier"),
                        result,
                    )
                    else -> result.notImplemented()
                }
            }

        // On-device text translation (Google ML Kit) — mirrors the iOS Apple-Translation channel.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bantera/translation")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // ML Kit model downloads have no cancellation API. The Dart
                    // job abandons its wait and ignores late results; a new
                    // language can use a separate translator immediately.
                    "cancelTranslation" -> result.success(null)
                    "translateTranscriptCues" -> TranslationBridge.translateCues(call, result)
                    "prepareTranslationAssets" -> TranslationBridge.prepareAssets(call, result)
                    "getSupportedTranslationLocales" ->
                        TranslationBridge.supportedLocales(call.argument<String>("sourceLocaleIdentifier"), result)
                    "getAllSupportedTranslationLocales" ->
                        TranslationBridge.supportedLocales(null, result)
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        photoSaveBridge?.permissionResult(requestCode, grantResults)
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
        RecordedAudioTranscriber(applicationContext, localeIdentifier ?: "en-US", result)
            .transcribe(File(inputPath))
    }
}

/**
 * On-device text translation via Google ML Kit. Fully on-device after a one-time per-language
 * model download (no API key, no server). Mirrors the iOS `bantera/translation` contract:
 * unsupported pairs reply `unsupported_locale`; missing models reply
 * `translation_assets_not_installed` so the Dart caller downloads via prepareTranslationAssets.
 */
private object TranslationBridge {
    private val main = Handler(Looper.getMainLooper())

    /** App locale identifier (e.g. "zh-CN", "en_US") → ML Kit language code, or null if unsupported. */
    private fun code(raw: String?): String? {
        if (raw.isNullOrBlank()) return null
        val base = raw.trim().replace('_', '-').split('-')[0].lowercase()
        return TranslateLanguage.fromLanguageTag(base)
    }

    fun translateCues(call: MethodCall, result: MethodChannel.Result) {
        val source = code(call.argument<String>("sourceLocaleIdentifier"))
        val target = code(call.argument<String>("targetLocaleIdentifier"))
        val cues = call.argument<List<Map<String, Any?>>>("cues") ?: emptyList()
        if (source == null || target == null) {
            result.error("unsupported_locale", "This language isn’t supported for on-device translation.", null)
            return
        }
        Thread {
            try {
                val mgr = RemoteModelManager.getInstance()
                val srcOk = Tasks.await(mgr.isModelDownloaded(TranslateRemoteModel.Builder(source).build()))
                val tgtOk = Tasks.await(mgr.isModelDownloaded(TranslateRemoteModel.Builder(target).build()))
                if (!srcOk || !tgtOk) {
                    main.post {
                        result.error("translation_assets_not_installed", "Translation models need to be downloaded.", null)
                    }
                    return@Thread
                }
                val translator = Translation.getClient(
                    TranslatorOptions.Builder().setSourceLanguage(source).setTargetLanguage(target).build(),
                )
                try {
                    val out = ArrayList<Map<String, Any?>>(cues.size)
                    for (cue in cues) {
                        val id = cue["id"]?.toString() ?: continue
                        val text = cue["text"]?.toString().orEmpty()
                        val translated = if (text.isBlank()) "" else Tasks.await(translator.translate(text))
                        out.add(mapOf("id" to id, "translatedText" to translated))
                    }
                    main.post { result.success(out) }
                } finally {
                    translator.close()
                }
            } catch (e: Exception) {
                Log.e(TRANSLATE_TAG, "translateCues failed", e)
                main.post { result.error("translation_failed", "The app could not translate this text.", null) }
            }
        }.start()
    }

    fun prepareAssets(call: MethodCall, result: MethodChannel.Result) {
        val source = code(call.argument<String>("sourceLocaleIdentifier"))
        val target = code(call.argument<String>("targetLocaleIdentifier"))
        if (source == null || target == null) {
            result.error("unsupported_locale", "This language isn’t supported for on-device translation.", null)
            return
        }
        Thread {
            try {
                val translator = Translation.getClient(
                    TranslatorOptions.Builder().setSourceLanguage(source).setTargetLanguage(target).build(),
                )
                try {
                    Tasks.await(translator.downloadModelIfNeeded(DownloadConditions.Builder().build()))
                    main.post { result.success(null) }
                } finally {
                    translator.close()
                }
            } catch (e: Exception) {
                Log.e(TRANSLATE_TAG, "prepareAssets failed", e)
                main.post { result.error("translation_download_failed", "Translation models could not be downloaded.", null) }
            }
        }.start()
    }

    fun supportedLocales(sourceRaw: String?, result: MethodChannel.Result) {
        val sourceCode = code(sourceRaw)
        if (sourceRaw != null && sourceCode == null) {
            result.success(emptyList<Map<String, Any?>>())
            return
        }
        Thread {
            try {
                val downloaded = Tasks.await(
                    RemoteModelManager.getInstance().getDownloadedModels(TranslateRemoteModel::class.java),
                ).map { it.language }.toSet()
                val items = TranslateLanguage.getAllLanguages()
                    .filter { sourceCode == null || it != sourceCode }
                    .map { lang ->
                        mapOf(
                            "identifier" to lang,
                            "displayName" to Locale.forLanguageTag(lang).getDisplayLanguage(Locale.getDefault()),
                            "isInstalled" to (downloaded.contains(lang) && (sourceCode == null || downloaded.contains(sourceCode))),
                        )
                    }
                main.post { result.success(items) }
            } catch (e: Exception) {
                Log.e(TRANSLATE_TAG, "supportedLocales failed", e)
                main.post { result.success(emptyList<Map<String, Any?>>()) }
            }
        }.start()
    }
}
