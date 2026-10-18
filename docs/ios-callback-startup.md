# Locked-screen callback startup, 19 October 2026

## Failure and correction

The callback owner marked startup as requested before `AiChatController.startCall`
finished awaiting saved AI consent. Native audio-route and mute notifications can
arrive during that await. They notify the controller's listeners while `calling`
is still false. The owner treated this as a hang-up and closed CallKit before
opening the live socket.

The owner now distinguishes startup from a call that has actually entered the
calling state. Route, mute and history notifications during startup do not end
the call. A rejected startup, explicit failure, real active-to-ended transition,
or CallKit end event still closes it. No permission is bypassed, and answering
does not open the app or present a consent dialog on the lock screen.

A separate race allowed an in-flight ringing-status poll to close an already
accepted call. The poll now rechecks that the callback is still ringing before
acting on its response.

Read-only production diagnostics showed the recent callbacks were marked
answered without a subsequent live-call start event. Those records are consistent
with this client race; they cannot prove the exact native event order on the phone.
No transcript, reminder text, audio or credential was needed for diagnosis.

## Verification

- The startup route/mute regression failed on the previous implementation: the
  callback ID became null instead of remaining active.
- All 28 callback, consent, transport and chat-entry tests passed after the fix.
- Additional coverage includes stale polling responses, startup refusal, hang-up
  while awaiting startup, system audio failure and active-call teardown.
- Static analysis of the changed Dart files passed without issues.
- Required unsigned debug build and signed release build passed; signature verified.
- Installed on the connected iPhone 17 Pro; device inventory confirms 2.18.6 (369).
  The app was not launched or physically tested by the agent.
- Version: 2.18.6 (369). App-only fix: no backend, schema or configuration changes.
- Physical locked-screen behavior must be checked on the installed build; unit
  tests do not verify iOS PushKit delivery or physical audio activation.

## Apple guidance consulted

CallKit reports audio activation separately from the answer action; applications
must coordinate their own connection and audio state rather than treating every
intermediate state as disconnection.

- https://developer.apple.com/documentation/callkit/cxproviderdelegate
- https://developer.apple.com/videos/play/wwdc2016/230/
