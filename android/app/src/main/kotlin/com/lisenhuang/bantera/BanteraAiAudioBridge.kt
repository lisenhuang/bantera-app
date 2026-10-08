package com.lisenhuang.bantera

import android.annotation.SuppressLint
import android.content.Context
import android.media.*
import android.media.audiofx.AcousticEchoCanceler
import android.media.audiofx.NoiseSuppressor
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.android.gms.tasks.Tasks
import java.io.File
import java.util.concurrent.Executors

class BanteraAiAudioBridge(private val context: Context, messenger: BinaryMessenger) : EventChannel.StreamHandler {
    private val main = Handler(Looper.getMainLooper())
    private val playback = Executors.newSingleThreadExecutor()
    private var sink: EventChannel.EventSink? = null
    @Volatile private var version = 0
    @Volatile private var outputVersion = 0
    private var recorder: AudioRecord? = null
    private var track: AudioTrack? = null
    private var echo: AcousticEchoCanceler? = null
    private var noise: NoiseSuppressor? = null
    private val progress = AiPlaybackProgress()
    private var drain: MethodChannel.Result? = null
    private var oldMode = AudioManager.MODE_NORMAL
    init {
        EventChannel(messenger, "bantera/ai_audio/input").setStreamHandler(this)
        MethodChannel(messenger, "bantera/ai_audio").setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "identifyLanguages" -> {
                        val texts = (call.arguments as? List<*>)?.filterIsInstance<String>()
                        if (texts == null || texts.size > 250 || texts.any { it.length > 4000 }) {
                            result.success(emptyList<Any>())
                        } else {
                            val identifier = LanguageIdentification.getClient()
                            val tasks = texts.map { text -> identifier.identifyPossibleLanguages(text).continueWith { task ->
                                val items = task.result.map { mapOf("language" to it.languageTag, "confidence" to it.confidence.toDouble()) }
                                mapOf("hypotheses" to items)
                            } }
                            Tasks.whenAllSuccess<Map<String, Any>>(tasks)
                                .addOnSuccessListener { result.success(it) }
                                .addOnFailureListener { result.success(emptyList<Any>()) }
                                .addOnCompleteListener { identifier.close() }
                        }
                    }
                    "storagePath" -> result.success(File(context.noBackupFilesDir, "bantera_ai").apply { mkdirs() }.absolutePath)
                    "start" -> { start(); result.success(null) }
                    "startPlayback" -> { start(playbackOnly = true); result.success(null) }
                    "feed" -> { feed(call.arguments as ByteArray); result.success(null) }
                    "playedFrames" -> result.success(progress.playedFrames(track?.playbackHeadPosition ?: 0))
                    "clear" -> { clear(); result.success(null) }
                    "drain" -> { drain?.success(null); drain = result; checkDrain() }
                    "speaker" -> { @Suppress("DEPRECATION")
                        (context.getSystemService(Context.AUDIO_SERVICE) as AudioManager).isSpeakerphoneOn = call.arguments == true
                        result.success(null)
                    }
                    "stop" -> { stop(); result.success(null) }
                    else -> result.notImplemented()
                }
            } catch (_: Exception) { stop(); result.error("audio_unavailable", "Audio is unavailable.", null) }
        }
    }
    override fun onListen(arguments: Any?, events: EventChannel.EventSink) { sink = events }
    override fun onCancel(arguments: Any?) { sink = null; stop() }
    @SuppressLint("MissingPermission")
    @Suppress("DEPRECATION")
    private fun start(playbackOnly: Boolean = false) {
        stop()
        val manager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        oldMode = manager.mode
        if (!playbackOnly) { manager.mode = AudioManager.MODE_IN_COMMUNICATION; manager.isSpeakerphoneOn = true }
        var input: AudioRecord? = null
        if (!playbackOnly) {
        input = AudioRecord(MediaRecorder.AudioSource.VOICE_COMMUNICATION, 16000, AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT, maxOf(6400, AudioRecord.getMinBufferSize(16000, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT)))
        recorder = input
        check(input.state == AudioRecord.STATE_INITIALIZED)
        if (AcousticEchoCanceler.isAvailable()) echo = AcousticEchoCanceler.create(input.audioSessionId)?.apply { enabled = true }
        if (NoiseSuppressor.isAvailable()) noise = NoiseSuppressor.create(input.audioSessionId)?.apply { enabled = true }
        }
        val output = AudioTrack.Builder().setAudioAttributes(AudioAttributes.Builder().setUsage(if (playbackOnly) AudioAttributes.USAGE_MEDIA else AudioAttributes.USAGE_VOICE_COMMUNICATION).setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build())
            .setAudioFormat(AudioFormat.Builder().setEncoding(AudioFormat.ENCODING_PCM_16BIT).setSampleRate(24000).setChannelMask(AudioFormat.CHANNEL_OUT_MONO).build())
            .setBufferSizeInBytes(maxOf(9600, AudioTrack.getMinBufferSize(24000, AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_16BIT)))
            .setTransferMode(AudioTrack.MODE_STREAM).build()
        track = output; output.play()
        val capture = input ?: return
        capture.startRecording()
        val token = version
        Thread {
            val buffer = ByteArray(3200)
            try {
                while (version == token) {
                    val count = capture.read(buffer, 0, buffer.size)
                    if (count <= 0) break
                    val bytes = buffer.copyOf(count)
                    main.post { if (version == token) sink?.success(bytes) }
                }
            } catch (_: Exception) { main.post { if (version == token) { sink?.error("interrupted", "Audio was interrupted.", null); stop() } } }
        }.apply { name = "Bantera AI microphone"; isDaemon = true; start() }
    }
    private fun feed(bytes: ByteArray) {
        val output = track ?: return
        val token = outputVersion
        playback.execute {
            if (token != outputVersion) return@execute
            var offset = 0
            try {
                while (offset < bytes.size && token == outputVersion) {
                    val count = output.write(bytes, offset, minOf(4800, bytes.size - offset))
                    if (count <= 0) break
                    offset += count
                    main.post { if (token == outputVersion) progress.written(count) }
                }
            } catch (_: Exception) { main.post { if (token == outputVersion) { sink?.error("interrupted", "Audio was interrupted.", null); stop() } } }
        }
    }
    private fun checkDrain() {
        val token = outputVersion
        // Queue the check after all writes, so an empty native queue cannot finish early.
        playback.execute { main.post {
            if (token != outputVersion || drain == null) return@post
            fun poll() {
                if (token != outputVersion || drain == null) return
                val head = progress.renderedInTrack(track?.playbackHeadPosition ?: 0)
                if (head >= progress.writtenFrames) { drain?.success(null); drain = null }
                else main.postDelayed({ poll() }, 25)
            }
            poll()
        } }
    }
    private fun clear() {
        outputVersion++; track?.pause()
        progress.clear(track?.playbackHeadPosition ?: 0)
        track?.flush(); track?.play()
        drain?.success(null); drain = null
    }
    @Suppress("DEPRECATION")
    fun stop() {
        version++; outputVersion++
        val hadAudio = recorder != null || track != null
        try { recorder?.stop() } catch (_: Exception) { }
        recorder?.release(); recorder = null
        try { track?.pause(); track?.flush() } catch (_: Exception) { }
        track?.release(); track = null
        echo?.release(); echo = null; noise?.release(); noise = null
        progress.reset(); drain?.success(null); drain = null
        if (hadAudio) { val manager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            manager.isSpeakerphoneOn = false; manager.mode = oldMode }
    }
    fun dispose() { stop(); playback.shutdownNow() }
}
