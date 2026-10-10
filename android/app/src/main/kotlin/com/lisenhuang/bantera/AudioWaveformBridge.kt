package com.lisenhuang.bantera

import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteOrder
import java.util.concurrent.Executors
import kotlin.math.abs
import kotlin.math.max

/** Bounded offline decoding with system codecs; does not acquire audio focus. */
class AudioWaveformBridge(messenger: BinaryMessenger) {
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val channel = MethodChannel(messenger, "bantera/audio_waveform")
    init {
        channel.setMethodCallHandler { call, result ->
            val path = call.argument<String>("path")
            if (call.method != "extract" || path == null) result.notImplemented()
            else worker.execute {
                val peaks = try { extract(path) } catch (_: Exception) { emptyList<Double>() }
                main.post { result.success(peaks) }
            }
        }
    }
    fun dispose() { channel.setMethodCallHandler(null); worker.shutdown() }

    private fun extract(path: String): List<Double> {
        val extractor = MediaExtractor()
        var decoder: MediaCodec? = null
        try {
            extractor.setDataSource(path)
            val track = (0 until extractor.trackCount).firstOrNull {
                extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME)?.startsWith("audio/") == true
            } ?: return emptyList()
            val format = extractor.getTrackFormat(track)
            val duration = format.getLong(MediaFormat.KEY_DURATION)
            if (duration <= 0 || duration > 600_000_000L) return emptyList()
            extractor.selectTrack(track)
            val codec = MediaCodec.createDecoderByType(format.getString(MediaFormat.KEY_MIME)!!)
            decoder = codec
            codec.configure(format, null, null, 0)
            codec.start()
            var rate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            var channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            var encoding = AudioFormat.ENCODING_PCM_16BIT
            val peaks = DoubleArray(64)
            val info = MediaCodec.BufferInfo()
            var inputDone = false
            val deadline = SystemClock.elapsedRealtime() + 10_000
            while (SystemClock.elapsedRealtime() < deadline) {
                if (!inputDone) {
                    val index = codec.dequeueInputBuffer(10_000)
                    if (index >= 0) {
                        val buffer = codec.getInputBuffer(index)!!
                        buffer.clear()
                        val count = extractor.readSampleData(buffer, 0)
                        if (count < 0) {
                            codec.queueInputBuffer(index, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        } else {
                            codec.queueInputBuffer(index, 0, count, extractor.sampleTime, 0)
                            extractor.advance()
                        }
                    }
                }
                val index = codec.dequeueOutputBuffer(info, 10_000)
                if (index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    val output = codec.outputFormat
                    rate = output.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                    channels = output.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                    encoding = if (output.containsKey(MediaFormat.KEY_PCM_ENCODING)) output.getInteger(MediaFormat.KEY_PCM_ENCODING) else AudioFormat.ENCODING_PCM_16BIT
                } else if (index >= 0) {
                    if (rate <= 0 || channels !in 1..8 || encoding !in listOf(AudioFormat.ENCODING_PCM_16BIT, AudioFormat.ENCODING_PCM_FLOAT)) return emptyList()
                    val buffer = codec.getOutputBuffer(index)!!.order(ByteOrder.LITTLE_ENDIAN)
                    buffer.position(info.offset)
                    buffer.limit(info.offset + info.size)
                    val bytesPerSample = if (encoding == AudioFormat.ENCODING_PCM_FLOAT) 4 else 2
                    val frames = info.size / (bytesPerSample * channels)
                    for (frame in 0 until frames) {
                        val time = info.presentationTimeUs + frame.toLong() * 1_000_000 / rate
                        val bucket = (time * 64 / duration).toInt().coerceIn(0, 63)
                        for (c in 0 until channels) {
                            val level = if (bytesPerSample == 4) abs(buffer.float.toDouble()) else abs(buffer.short.toInt()) / 32768.0
                            if (level.isFinite()) peaks[bucket] = max(peaks[bucket], level.coerceIn(0.0, 1.0))
                        }
                    }
                    codec.releaseOutputBuffer(index, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) return peaks.toList()
                }
            }
            return emptyList()
        } finally {
            try { decoder?.stop() } catch (_: Exception) {}
            decoder?.release()
            extractor.release()
        }
    }
}
