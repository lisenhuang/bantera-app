package com.lisenhuang.bantera

import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.os.SystemClock
import java.io.File
import java.io.IOException

/** File codec only. Does not use AudioManager, AudioRecord or AudioTrack. */
internal object LocalAudioEncoder {
    fun encode(pcm: ByteArray, rate: Int, channels: Int, output: File) {
        require(rate > 0 && channels in 1..2 && pcm.isNotEmpty())
        val format = MediaFormat.createAudioFormat(MediaFormat.MIMETYPE_AUDIO_AAC, rate, channels).apply {
            setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC)
            setInteger(MediaFormat.KEY_BIT_RATE, 64000 * channels)
        }
        val codec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_AUDIO_AAC)
        var muxer: MediaMuxer? = null
        var started = false
        try {
            codec.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            codec.start()
            val writer = MediaMuxer(output.path, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
            muxer = writer
            val info = MediaCodec.BufferInfo()
            var position = 0
            var eos = false
            var track = -1
            val deadline = SystemClock.elapsedRealtime() + 120_000
            while (true) {
                if (SystemClock.elapsedRealtime() > deadline) throw IOException("Audio encode timed out")
                if (!eos) {
                    val index = codec.dequeueInputBuffer(10000)
                    if (index >= 0) {
                        val buffer = codec.getInputBuffer(index)!!
                        buffer.clear()
                        val size = minOf(buffer.remaining(), pcm.size - position) / (channels * 2) * (channels * 2)
                        val time = position.toLong() * 1_000_000 / (rate * channels * 2)
                        if (size == 0) {
                            codec.queueInputBuffer(index, 0, 0, time, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            eos = true
                        } else {
                            buffer.put(pcm, position, size)
                            position += size
                            codec.queueInputBuffer(index, 0, size, time, 0)
                        }
                    }
                }
                val index = codec.dequeueOutputBuffer(info, 10000)
                if (index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    if (started) throw IOException("Unexpected audio format change")
                    track = writer.addTrack(codec.outputFormat)
                    writer.start()
                    started = true
                } else if (index >= 0) {
                    val buffer = codec.getOutputBuffer(index)!!
                    if (info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG == 0 && info.size > 0) {
                        if (!started) throw IOException("Missing audio format")
                        buffer.position(info.offset)
                        buffer.limit(info.offset + info.size)
                        writer.writeSampleData(track, buffer, info)
                    }
                    codec.releaseOutputBuffer(index, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) break
                }
            }
            if (!started) throw IOException("No encoded audio")
            writer.stop()
            started = false
        } finally {
            try { codec.stop() } catch (_: Exception) {}
            codec.release()
            if (started) try { muxer?.stop() } catch (_: Exception) {}
            muxer?.release()
        }
    }
}
