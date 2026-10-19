# 🔊 How we stopped Bantera AI interrupting itself on iPhone

[← Back to the app README](../README.md)

**Investigation:** 14 October 2026. **Documentation expanded:** 19 October 2026.
**Test device:** iPhone 17 Pro (iPhone18,1), iOS 27.0.1 (24A446).

> The speaker played the AI's voice, the microphone picked some of it up, and
> the AI treated its own voice as someone interrupting it. Apple voice processing
> was enabled, but that flag did not mean the outgoing microphone signal was
> already free of echo. We retained Apple's cancellation and protected the
> measured settling interval with a bounded microphone guard.

This account uses the measurements recorded during the original investigation,
checked against the current native implementation. It is not a new device test.
The fix was committed in [1bf30b2](https://github.com/lisenhuang/bantera-app/commit/1bf30b250fc5fe4dc81285784bba06ee49757099).

## 1. What the user experienced

Calls could produce repeated fragments such as “Welcome back” and then stop
speaking, even in a quiet room with nobody touching the phone. It happened most
at the beginning, improved after a few exchanges, and could return later.

```text
AI voice -> iPhone speaker -> sound through the room -> microphone
   ^                                                     |
   |                  residual echo survives             v
   +--- starts another reply <-- AI detects an interruption
```

This is acoustic echo, not necessarily an audible squeal. It can be enough to
trigger the model's speech detection without sounding like obvious feedback to
the person listening.

## 2. How we isolated the cause 🔬

We used an explicitly authorised physical-iPhone XCTest through Bantera's actual
native audio bridge. It played a known synthetic speech fixture through the
speaker and measured the microphone signal that would leave the bridge.
**There was no Gemini connection in this test.** This separated the local audio
problem from model behavior, prompts, quotas and network timing.

```text
Known synthetic speech (24 kHz PCM)
             |
             v
Bantera playback converter -> VoiceProcessingIO -> physical speaker
                                      ^                 |
                              playback reference        | room echo
                                                        v
Metrics only <- echo guard <- capture converter <- processed microphone
 RMS / peak     (app)           16 kHz PCM         (Apple voice processing)
```

The microphone samples were processed in memory; the test did not save or upload
a microphone recording. The fixture on disk contained synthetic speech, not the
user's conversation. The user confirmed that the room was quiet and the phone
untouched when a later spike needed investigating.

| Measurement | What it tells us | What it does not prove |
| --- | --- | --- |
| RMS | Average signal energy leaving the bridge | Whether a person spoke or the model would interrupt |
| Peak | Largest sample magnitude | A universal acceptable echo level |
| Frames with peak > 900 | Number of captured buffers crossing our diagnostic threshold | Google's voice-activity threshold or a duration in seconds |
| Route and processing flags | Actual speaker/receiver route and configured processing state | Successful acoustic cancellation |
| Capture/playback counters and errors | Whether the bridge continues moving audio | That a full AI call works end to end |

Values below use signed 16-bit PCM amplitude units, not decibels or sound-pressure
levels. Energy-only comparisons require a quiet room: real speech or room noise
would otherwise look like leakage too.

## 3. Before the fix: the first reply leaked

An opt-in XCTest played synthetic speech through Bantera's actual native call
pipeline. No Gemini connection was used, and no microphone audio was saved.
Only signal-energy summaries were printed. The test used a mono 24 kHz signed
16-bit PCM fixture copied to Documents/bantera-echo-speech.pcm.

| Phase | Outgoing microphone RMS (Int16 units) | Peak | Frames above peak 900 |
| --- | ---: | ---: | ---: |
| Quiet | 26.65 | 552 | 0 |
| First speech | 401.15 | 4597 | 54 |
| Repeated speech | 2.46 | 42 | 0 |
| Speaker route change | 152.32 | 2852 | 12 |

The session remained playAndRecord/voiceChat at 48 kHz with voice processing
enabled. Its 500 ms guard expired while residual echo remained. The
strict correlation filter suppressed no additional samples in this baseline.

**What we established:** the failure was in the outgoing audio path even without
a model connection. It was not simply “echo cancellation was switched off.”
The first speech leaked far more than repeated speech, and route changes caused
another transient.

**Our engineering interpretation:** this pattern is consistent with the acoustic
filter settling or re-adapting. We cannot inspect Apple's internal filter state
or prove its internal algorithm's cause. A running duplex unit, a successful
readiness check, and silent render callbacks do not establish acoustic convergence.
The practical cause was letting that transient reach the AI after our earlier
protective interval had already ended.

A separate experiment using a one-second swept connection tone did **not**
reliably suppress subsequent speech echo. Do not ship that experiment as a fix.

## 4. What we tried and rejected

- Apple's hardware-AEC/RemoteIO path improved the short startup test (54 loud
  frames became 1), but after a minute of silence produced 28 loud frames and
  RMS 269.94 despite the enabled flag remaining true. The user confirmed a quiet
  room and untouched phone. It is not used in the shipped implementation.
- Disabling VoiceProcessingIO automatic gain control alone reduced startup
  leakage but did not eliminate it (18 loud frames). A one-second guard still
  allowed nine loud frames; a two-second guard allowed six after a mid-reply
  receiver/speaker switch. Measurements localized the remaining transient to
  the settling interval, rather than all subsequent speech.

## 5. The shipped mitigation 🛠️

Retain Apple's duplex VoiceProcessingIO, use the active hardware sample rate
(48 kHz in these measurements), and convert to 16 kHz capture / 24 kHz playback. Disable automatic gain control **after**
unit initialization, read the setting back, and reapply it after sample-rate
reinitialization. Echo cancellation and noise suppression remain enabled.

Protect the microphone uplink for a maximum of 2.5 seconds from the first
actual speaker audio after startup or a route discontinuity. After 2 seconds
of continuous silent render output, rearm the same bounded guard only when
speaker audio starts again. Quiet-room capture remains available during the idle
period. The guard does not restart for continuous playback or pauses shorter than 2 seconds.
The user explicitly accepted this protective window after reviewing the
interruption tradeoff.

```text
FIRST SPEAKER REPLY / REPLY AFTER >= 2 s SILENT OUTPUT

Speaker audio:      |========== AI speaking ==================>
Microphone uplink:  | zeroed, up to 2.5 s | normal filtered audio
                    ^                    ^
                 actual sound       user can interrupt
                 starts             normally again

During idle:        microphone remains available
Continuous reply:  guard does not keep restarting
Short pause < 2 s:  guard does not rearm
Route change:      reset stale history; protect the new speaker start
```

The duration is counted using **captured audio samples**, not time since opening
the call or enqueuing playback. Audio rendering can run ahead; consuming the guard
on that clock would expose the returning echo too early. At 16 kHz, the configured
maximum covers 40,000 microphone samples. Protected samples are zeroed while the
capture pipeline continues running.

Outside this window, the residual guard suppresses only a strongly verified
copy of actual output. It compares delayed/filtered playback against capture,
with full-band checks to avoid mistaking a new user syllable for echo. It is an
extra safeguard, not a replacement for Apple's acoustic echo cancellation (AEC).

This is a deliberate UX tradeoff: speech over those initial 2.5 seconds is not
sent to the model. Outside that interval, independent speech and double-talk
remain enabled. It prevents the measured settling transient from prematurely
interrupting the AI; it does not claim that iOS acoustics become perfect.
No new SDK, backend, model or dependency is needed. No microphone recording is
stored or uploaded by these synthetic-fixture tests.

## 6. After the fix: measured results ✅

The final candidate passed the physical iPhone test through the actual native
audio bridge, with the 2-second idle rearm and 2.5-second protection enabled:

| Phase | Outgoing microphone RMS (Int16 units) | Peak | Frames above peak 900 |
| --- | ---: | ---: | ---: |
| Quiet | 9.69 | 82 | 0 |
| First reply | 9.35 | 202 | 0 |
| Immediate second reply | 5.71 | 274 | 0 |
| Receiver/speaker switch | 2.01 | 76 | 0 |
| Switch during playback | 0.76 | 11 | 0 |
| Reply after 10-second pause | 8.77 | 140 | 0 |
| Reply after 60-second pause | 0.44 | 3 | 0 |

Voice processing stayed enabled, the route remained on speaker after each
switch, and capture/playback continued without bridge errors. This is a
synthetic-speech acoustic result, not a full Gemini conversation or a guarantee
for every volume and environment. Real human speech during the protective
window is deliberately suppressed; human double-talk outside it still needs
real-world feedback.

During the original investigation, twenty-four native simulator regressions passed. All fourteen pure echo-guard
tests also passed against the final source, including the exact guard duration,
idle microphone availability, and independent speech preservation. The physical
test was opt-in and reported energy metrics only. These measurements include
the app guard's zeroing; they demonstrate the combined mitigation, not an
improvement attributable to Apple's cancellation alone.

## 7. Reproducing the investigation

Physical execution needs the user's explicit permission and an unlocked phone.
Use a Profile test host with ENABLE_TESTABILITY=YES (Flutter's debug JIT host
cannot launch under this device's XCTest runner). Enable
BANTERA_TEST_AUDIO_HARDWARE=1 only for that test run. Keep the phone unobstructed
and the room quiet; people speaking during the check invalidate energy-only
comparisons. Speaker/receiver routing and real human double-talk need separate
checks. A successful XCTest launch alone is not an acoustic pass.

The opt-in test is `RunnerTests.testSpeakerSpeechLeakage` in
[RunnerTests.swift](../ios/RunnerTests/RunnerTests.swift). It exercises quiet,
first reply, immediate reply, route switching before/during playback, and replies
after 10-second and 60-second pauses. `BANTERA_ASSERT_QUIET_ROOM=1` additionally
enables the test's loud-buffer assertion (at most five per phase). Without that
option, inspect the printed metrics: an XCTest pass alone is not an echo pass.
The recorded final run above had zero such buffers in every phase.

For future changes:

1. Run pure signal and native simulator regressions first. Include
   `BanteraEchoGuardTests`, readiness, PCM conversion and audio ownership checks.
2. If a physical acoustic check is explicitly authorised, use the same synthetic
   fixture and record device/OS, route, volume, processing state and phase metrics.
   Use a quiet room and an unobstructed stationary phone.
3. Check route switches and pauses, not just the first greeting. Do not accept
   `echoCancellation=true` as the sole success criterion.
4. Separately check real human interruption outside the guard and real AI calls,
   including locked-screen callbacks when affected. The isolated test cannot
   establish these behaviors.
5. Report what was verified and what remains untested. A build, installation or
   simulator pass cannot prove speaker/microphone behavior on a physical iPhone.

## 8. Where the implementation lives 🧭

| File / symbol | Responsibility |
| --- | --- |
| [AppDelegate.swift](../ios/Runner/AppDelegate.swift): `BanteraPhoneAudio` | Shared duplex VoiceProcessingIO, native-rate format/conversion, AGC disable/readback, render reference and microphone filtering |
| [AppDelegate.swift](../ios/Runner/AppDelegate.swift): `BanteraAudioReadiness` | Startup readiness; this must not be interpreted as acoustic convergence |
| [BanteraEchoGuard.swift](../ios/Runner/BanteraEchoGuard.swift) | Captured-sample protection, two-second idle rearm, route reset and residual echo matching |
| [RunnerTests.swift](../ios/RunnerTests/RunnerTests.swift) | Pure-signal regressions and explicitly opt-in physical acoustic tests |
| [CLAUDE.md](../CLAUDE.md#ios-ai-callback-regression-gate) | Callback regression and physical-test permission rules |

`BanteraEchoGuard` has a 500 ms default constructor value for other/test uses;
**the production `BanteraPhoneAudio` explicitly passes 2500 ms**. Read the call
site before changing a default or assuming the deployed guard is 500 ms.

## What this result means

The selected mitigation eliminated the measured loud leakage in the recorded
quiet-room phases, including after pauses and route switches. It deliberately
sacrifices immediate interruption during the protected interval. It does not
promise perfect cancellation at every volume, in every room, on every iPhone or
OS version. Those conditions need their own measurements.

The durable lesson is to measure the signal that actually leaves the app,
exercise startup **and** later transitions, and retain regression coverage for
the timing behavior that produced the fix.

## Platform references

- [Apple voice processing overview](https://developer.apple.com/videos/play/wwdc2023/10235/): capture and render through voice processing; system microphone modes remain user controlled.
- [Apple voiceChat mode](https://developer.apple.com/documentation/avfaudio/avaudiosession/mode-swift.struct/voicechat): setting a session mode alone is insufficient; use VoiceProcessingIO or AVAudioEngine voice processing.
- [Apple hardware echo-cancelled input](https://developer.apple.com/documentation/avfaudio/avaudiosession/setprefersechocancelledinput(_:)): a separate option for supported recent iPhones using playAndRecord/default; query availability in that configuration, and verify enabled state after activation and route changes.
- [WebRTC's iOS audio unit implementation](https://webrtc.googlesource.com/src/+/refs/heads/main/sdk/objc/native/src/audio/voice_processing_audio_unit.mm): use the active device rate, matching capture/render PCM formats and a duplex VoiceProcessingIO unit.
