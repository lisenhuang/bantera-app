# 🔊 Why Bantera AI interrupted itself, and how we fixed it

[← README](../README.md) · Tested **14 October 2026** on **iPhone 17 Pro, iOS 27.0.1**

## The cause

**The microphone picked up the AI's speaker audio. The AI mistook that echo for the user interrupting.**

```mermaid
flowchart LR
    A[AI speaks] --> B[iPhone speaker]
    B -->|Sound travels through the room| C[Microphone]
    C -->|Residual echo reaches AI| D[AI thinks the user spoke]
    D --> E[AI stops its reply]
```

Apple's echo cancellation **was enabled**, but some echo still escaped at startup, after speaker/receiver switches, and after pauses. Our earlier **0.5-second protection ended too soon**.

The measurements suggest the acoustic filter needed time to settle again. We cannot inspect Apple's internal filter, so this is an explanation supported by the observed pattern, not a confirmed iOS defect.

## How we found it 🔬

With permission, we played **synthetic speech through the actual app audio pipeline on the iPhone**, in a quiet room with the phone untouched. We measured the outgoing microphone signal.

**No AI connection was needed. No microphone recording was saved or uploaded.** This reproduced the leakage locally, separating it from prompts, network problems and API keys.

| Test phase | Loud microphone buffers before | After the fix |
| --- | ---: | ---: |
| First reply | 54 | **0** |
| Immediate next reply | 0 | **0** |
| Speaker/receiver switch | 12 | **0** |
| Switch during playback | Not recorded in baseline | **0** |
| Reply after 10-second pause | Not recorded in baseline | **0** |
| Reply after 60-second pause | Not recorded in baseline | **0** |

“Loud” means a captured buffer with peak amplitude above 900 in 16-bit PCM: our diagnostic threshold, not the AI's speech threshold. Results measure **Apple processing plus our guard**, including its brief muting.

A warm-up tone, a different hardware echo-cancellation path, and shorter guards did not reliably handle all tested conditions.

## The fix 🛠️

1. **Keep Apple's VoiceProcessingIO** for both microphone capture and speaker playback.
2. **Disable automatic gain control**, which reduced the measured leakage. Verify the setting after initialization and reapply it after sample-rate changes.
3. **Protect up to the first 2.5 seconds of speaker output:** zero outgoing microphone samples while the audio pipeline keeps running. Count captured samples, so queued playback cannot consume the protection early.
4. **Rearm after route changes or at least 2 seconds of silent output.** Start protection when speaker audio resumes. Keep the microphone available during idle; do not rearm during continuous speech or shorter pauses.

```text
AI starts speaking       2.5 seconds later
        |                       |
Speaker |=======================|=================>
Mic     | briefly protected     | normal filtering
```

Outside that window, the residual-echo filter suppresses strongly matched speaker audio while allowing independent speech.

**Tradeoff:** the user cannot interrupt during the protected interval. The user accepted this brief delay. It is not a whole-reply microphone mute.

## Keep it working

The recorded final test had **zero loud buffers in every phase**, with no bridge errors. This does not guarantee every room, volume or device, or prove a complete AI call works.

- Run native signal, readiness and routing regressions.
- With explicit permission, repeat the physical test after startup, route switches, and 10/60-second pauses.
- Separately verify human interruption outside the guard and locked-screen callbacks. An enabled flag or successful build is insufficient.

**Code:** [audio pipeline](../ios/Runner/AppDelegate.swift) · [echo guard](../ios/Runner/BanteraEchoGuard.swift) · [tests](../ios/RunnerTests/RunnerTests.swift)

**Evidence:** [original measurements and test procedure](https://github.com/lisenhuang/bantera-app/blob/1bf30b250fc5fe4dc81285784bba06ee49757099/docs/ios-echo-investigation.md) · [fix commit](https://github.com/lisenhuang/bantera-app/commit/1bf30b250fc5fe4dc81285784bba06ee49757099) · [Apple voice processing](https://developer.apple.com/videos/play/wwdc2023/10235/)
