package com.lisenhuang.bantera

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException
import java.nio.ByteBuffer
import java.nio.ByteOrder

/** Shared file decoder for transcription, AAC verification and AI retries. */
internal object LocalAudioDecoder {
    private const val TARGET_RATE = 16000
    /** Returns (16-bit PCM bytes, sampleRate, channelCount). WAV via header parse, else MediaCodec. */
    fun readSourcePcm(input: File): Triple<ByteArray, Int, Int> {
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
        val deadline = android.os.SystemClock.elapsedRealtime() + 120_000
        try {
            while (!sawOutputEos) {
                if (android.os.SystemClock.elapsedRealtime() > deadline || out.size() > 64 * 1024 * 1024) throw IOException("Audio decode limit exceeded")
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
                        outBuf.position(info.offset)
                        outBuf.limit(info.offset + info.size)
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
    fun downmixAndResample(pcm: ByteArray, srcRate: Int, channels: Int): ByteArray {
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

}
