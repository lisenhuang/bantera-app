package com.lisenhuang.bantera

import org.junit.Assert.assertEquals
import org.junit.Test

class AiPlaybackProgressTest {
    @Test fun queuedAudioDoesNotCountUntilRendered() {
        val progress = AiPlaybackProgress()
        progress.written(48000)
        assertEquals(0L, progress.playedFrames(0))
        assertEquals(12000L, progress.playedFrames(12000))
        assertEquals(24000L, progress.playedFrames(24000))
        assertEquals(24000L, progress.playedFrames(24000))
    }

    @Test fun interruptionKeepsHeardFramesAndDiscardsUnplayedFrames() {
        val progress = AiPlaybackProgress()
        progress.written(48000)
        progress.clear(6000)
        assertEquals(6000L, progress.playedFrames(0))
        progress.written(24000)
        assertEquals(12000L, progress.playedFrames(6000))
        assertEquals(18000L, progress.playedFrames(12000))
    }

    @Test fun newPlaybackSessionStartsFromZero() {
        val progress = AiPlaybackProgress()
        progress.written(48000)
        progress.clear(6000)
        progress.reset()
        assertEquals(0L, progress.playedFrames(0))
        progress.written(2400)
        assertEquals(1200L, progress.playedFrames(1200))
    }

    @Test fun unsignedHeadAndRolloverAreHandled() {
        val progress = AiPlaybackProgress()
        repeat(5) { progress.written(Int.MAX_VALUE - 1) }
        assertEquals(0xfffffffeL, progress.playedFrames(-2))
        assertEquals(0x10000000aL, progress.playedFrames(10))
    }
}
