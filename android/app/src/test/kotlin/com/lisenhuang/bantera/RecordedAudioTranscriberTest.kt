package com.lisenhuang.bantera

import android.os.Bundle
import android.os.Looper
import android.speech.SpeechRecognizer
import io.flutter.plugin.common.MethodChannel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowSpeechRecognizer
import java.time.Duration

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [33], manifest = Config.NONE)
class RecordedAudioTranscriberTest {
    private val replies = mutableListOf<Any?>()
    private val result = object : MethodChannel.Result {
        override fun success(result: Any?) { replies.add((result as Map<*, *>)["transcriptText"]) }
        override fun error(code: String, message: String?, details: Any?) { replies.add(code) }
        override fun notImplemented() = throw AssertionError("Unexpected method")
    }

    private fun attempt(): RecordedAudioTranscriber {
        val attempt = RecordedAudioTranscriber(RuntimeEnvironment.getApplication(), "en-NZ", result)
        attempt.recognise(ByteArray(32000)) // One second of 16 kHz mono PCM.
        shadowOf(Looper.getMainLooper()).idle()
        return attempt
    }

    private fun words(text: String) = Bundle().apply {
        putStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION, arrayListOf(text))
    }

    @Test fun silentProviderReleasesRecognizerAndLateResultCannotAffectRetry() {
        val stalled = attempt()
        val recognizer = shadowOf(ShadowSpeechRecognizer.getLatestSpeechRecognizer())
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofSeconds(17))
        assertEquals(listOf("speech_timeout"), replies)
        assertTrue(recognizer.isDestroyed)

        val retry = attempt()
        stalled.onResults(words("late result"))
        retry.onResults(words("It is five dollars."))
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMinutes(1))
        assertEquals(listOf("speech_timeout", "It is five dollars."), replies)
    }

    @Test fun completedSegmentsSurviveMissingEndCallback() {
        val session = attempt()
        session.onSegmentResults(words("It is"))
        session.onSegmentResults(words("five dollars."))
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofSeconds(17))
        session.onEndOfSegmentedSession()
        assertEquals(listOf("It is five dollars."), replies)
    }

    @Test fun segmentedSessionCompletesImmediatelyWhenProviderFinishes() {
        val session = attempt()
        session.onSegmentResults(words("five dollars"))
        session.onEndOfSegmentedSession()
        assertEquals(listOf("five dollars"), replies)
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMinutes(1))
        assertEquals(1, replies.size)
    }
}
