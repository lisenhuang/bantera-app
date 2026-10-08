package com.lisenhuang.bantera

/** Rendered PCM frames, not queued audio. Accessed on the main thread. */
internal class AiPlaybackProgress {
    var writtenFrames = 0L
        private set
    private var completedFrames = 0L
    private var previousHead = 0L
    private var headWraps = 0L

    fun written(bytes: Int) { writtenFrames += bytes / 2 }

    fun renderedInTrack(headPosition: Int): Long {
        // AudioTrack exposes an unsigned 32-bit frame counter as a signed Int.
        val head = headPosition.toLong() and 0xffffffffL
        if (head < previousHead) headWraps += 1L shl 32
        previousHead = head
        return minOf(headWraps + head, writtenFrames)
    }

    fun playedFrames(headPosition: Int): Long = completedFrames + renderedInTrack(headPosition)

    fun clear(headPosition: Int) {
        completedFrames = playedFrames(headPosition)
        writtenFrames = 0
        previousHead = 0
        headWraps = 0
    }

    fun reset() {
        completedFrames = 0
        writtenFrames = 0
        previousHead = 0
        headWraps = 0
    }
}
