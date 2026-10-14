# iOS speaker echo investigation (14 October 2026)

Device: iPhone 17 Pro (iPhone18,1), iOS 27.0.1 (24A446).

Apple's VoiceProcessingIO being enabled does **not** establish that its acoustic
filter has converged. Silent duplex callbacks alone cannot exercise the speaker
return path. Check audio measurements as well as the configuration flags.

## References

- [Apple voice processing overview](https://developer.apple.com/videos/play/wwdc2023/10235/): capture and render through voice processing; system microphone modes remain user controlled.
- [Apple voiceChat mode](https://developer.apple.com/documentation/avfaudio/avaudiosession/mode-swift.struct/voicechat): setting a session mode alone is insufficient; use VoiceProcessingIO or AVAudioEngine voice processing.
- [Apple hardware echo-cancelled input](https://developer.apple.com/documentation/avfaudio/avaudiosession/setprefersechocancelledinput(_:)): a separate option for supported recent iPhones using playAndRecord/default; query availability in that configuration, and verify enabled state after activation and route changes.
- [WebRTC's iOS audio unit implementation](https://webrtc.googlesource.com/src/+/refs/heads/main/sdk/objc/native/src/audio/voice_processing_audio_unit.mm): use the active device rate, matching capture/render PCM formats and a duplex VoiceProcessingIO unit.

## Physical baseline

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
enabled. Its 500 ms guard expired while audible residual echo remained. The
strict correlation filter suppressed no additional samples in this baseline.

A separate experiment using a one-second swept connection tone did **not**
reliably suppress subsequent speech echo. Do not ship that experiment as a fix.

## Running the acoustic test

Physical execution needs the user's explicit permission and an unlocked phone.
Use a Profile test host with ENABLE_TESTABILITY=YES (Flutter's debug JIT host
cannot launch under this device's XCTest runner). Enable
BANTERA_TEST_AUDIO_HARDWARE=1 only for that test run. Keep the phone unobstructed
and the room quiet; people speaking during the check invalidate energy-only
comparisons. Speaker/receiver routing and real human double-talk need separate
checks. A successful XCTest launch alone is not an acoustic pass.

## Rejected alternatives

- Apple's hardware-AEC/RemoteIO path improved the short startup test (54 loud
  frames became 1), but after a minute of silence produced 28 loud frames and
  RMS 269.94 despite the enabled flag remaining true. The user confirmed a quiet
  room and untouched phone. It is not used in the shipped implementation.
- Disabling VoiceProcessingIO automatic gain control alone reduced startup
  leakage but did not eliminate it (18 loud frames). A one-second guard still
  allowed nine loud frames; a two-second guard allowed six after a mid-reply
  receiver/speaker switch. Measurements localized the remaining transient to
  the settling interval, rather than all subsequent speech.

## Selected mitigation

Retain Apple's duplex VoiceProcessingIO and existing 48 kHz hardware / 16 kHz
capture / 24 kHz playback conversions. Disable automatic gain control **after**
unit initialization, read the setting back, and reapply it after sample-rate
reinitialization. Echo cancellation and noise suppression remain enabled.

Protect the microphone uplink for a maximum of 2.5 seconds from the first
actual speaker audio after startup or a route discontinuity. After 2 seconds
of continuous silent render output, rearm the same bounded guard only when
speaker audio starts again. Quiet-room capture remains available during the idle
period. The guard does not restart for continuous playback or pauses shorter than 2 seconds.
The user explicitly accepted this protective window after reviewing the
interruption tradeoff.

This is a deliberate UX tradeoff: speech over those initial 2.5 seconds is not
sent to the model. Outside that interval, independent speech and double-talk
remain enabled. It prevents the measured settling transient from prematurely
interrupting the AI; it does not claim that iOS acoustics become perfect.
No new SDK, backend, model or dependency is needed. No microphone recording is
stored or uploaded by these synthetic-fixture tests.

## Final verification

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

Twenty-four native simulator regressions passed. All fourteen pure echo-guard
tests also passed against the final source, including the exact guard duration,
idle microphone availability, and independent speech preservation. The physical
test was opt-in and reported energy metrics only.
