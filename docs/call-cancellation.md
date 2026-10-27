# Call rollback and Practice navigation

## Current status: 3.31.3 (501)

The owner reported that the cancellation changes in 499/500 did not stop ringing
and introduced immediate termination after answering. Call debugging is paused.
The native bridge, Dart call payload handling, native tests, API call delivery,
and website call-setting copy have been restored exactly to their pre-task HEAD.
The failed monitor, report coordinator and new backend status endpoint/queue
are removed. This restores earlier behavior; it does not claim to solve the
original Android-to-iPhone ringing problem.

The existing TURN-only server policy is unchanged. No database rollback or
practice/progress/audio deletion is involved. Production restores the retained
API 1.50.0 and website 0.25.0 images. Source rollback versions are API 1.50.2 and
website 0.25.2 to preserve monotonic versioning for a future build.

The independent unfinished-Practice-per-level fix remains. AI word explanations
now open over Practice using the root navigator, leaving Practice selected below
the entire Back animation. An existing hidden AI route is disposed before the
new explanation request is delivered. The prior workaround that restored the
Practice tab after returning to Chats has been removed.

A navigation regression checks the hidden-pane-to-root handoff, one active AI
view, the interactive iOS back gesture and every sampled exit-animation frame.
All 31 focused navigation/callback/CallKit/audio Flutter tests passed, along with
the unfinished-Practice-per-level regression. Physical calls remain unverified;
installation does not authorize launching or testing the phone.

Final verification for 501: 32 focused Flutter tests and five native iOS
simulator tests passed. The simulator initially stalled during boot; one restart
resolved it and all selected native tests passed. Debug and release iOS builds
and the restored backend build succeeded. Focused static analysis reported only
eight existing informational notices, with no errors or warnings. The signed app
was installed without launching or testing the physical phone. No Git commit,
push or store submission was performed.

## Historical attempts (reverted)

The following records describe reverted implementations, not current behavior.

### Initial attempt

App 3.31.1 (499), API 1.50.1, website 0.25.1.

A human caller's hang-up previously depended on the receiving phone's Flutter
chat socket. That socket can be suspended while native PushKit/CallKit still
rings. The server also awaited APNs delivery in the caller's socket receive
loop, delaying subsequent cancellation events. Stale socket sends were unbounded.

The backend now dispatches incoming-call notifications through a bounded hosted
queue with independent scopes, four consumers and the original call deadline.
It skips cancelled/expired queued calls. Chat socket sends have a three-second
limit. Existing call.cancel/call.end protocol messages remain supported.

Incoming human-call payloads add a two-minute, read-only capability scoped to
that call and recipient. Native iOS code checks the production API while ringing,
without waiting for Flutter startup, session-token refresh or socket connection.
The capability is sent in a header, never a URL, and the response is not cached.
A confirmed ended state stops CallKit; accepted state stops another device's
ringing. Network/authentication errors are unknown and do not dismiss a call.
The existing 45-second expiry still bounds ringing; iOS can end the background
execution allowance sooner, in which case the pending call ends cleanly.

The monitor stops synchronously when CallKit answers or ends the call. In-flight
responses cannot terminate that answered call. AI callbacks do not use this
monitor, and existing audio-startup and mainland-China restrictions remain.
No cancellation-only VoIP push is sent. PushKit incoming calls are still reported
promptly to CallKit, as Apple requires.

TURN-only routing uses the existing server setting and existing Cloudflare relay.
It improves connection consistency across networks, but is independent of the
signaling cancellation fix. It uses more relay traffic and fails closed if relay
credentials are unavailable. Updated clients do not fall back to STUN/direct ICE.

Compatibility: additive payload/endpoint changes, no migration and no new secret
or configuration. Old clients ignore the new capability and retain their existing
polling/expiry behavior. The native cancellation improvement requires this app
update. Backend deploy must precede installation.

Validation: backend cancellation/capability/expiry tests, delayed APNs and stalled
socket regressions, native iOS simulator monitor tests including late-answer
races and network errors, and protected callback/CallKit/audio regressions.
Simulator tests cannot establish real APNs delivery or locked-screen audio.
Physical Redmi-to-iPhone cancellation and answered-call audio checks are left to
the owner. Installation does not launch or test the physical iPhone.

Apple reference: https://developer.apple.com/documentation/pushkit/responding-to-voip-notifications-from-pushkit

Final verification: 27 Flutter callback/CallKit/audio tests and eight native iOS
simulator tests passed. The native suite was rerun sequentially after resolving
a shared Flutter build-cache conflict. Debug and release builds succeeded.
The signed app was installed and the device inventory confirmed 3.31.1 (499).
The physical iPhone was not launched or tested. Backend 1.50.1 and website
0.25.1 were verified live before installation; production remains TURN-only.

## Follow-up: app 3.31.2 (500)

The owner reported continued system ringing after installing 499. Code review
identified two additional native registration races: a duplicate report failure
could remove the tracking entry before another report succeeded, and cancellation
could remove the entry before an asynchronous CallKit success callback arrived.
Either ordering could leave a system call without its expiry timer or monitor.

Incoming reports now share a per-call completion coordinator. Duplicate failures
cannot remove an active/pending call; the first successful report activates its
lifecycle exactly once. A successful report arriving after cancellation explicitly
ends that system call again. Tests cover both duplicate completion orders, all
reports failing, and cancellation before registration completes.

This follow-up is app-only and uses the already deployed API 1.50.1. It does not
require a new Android build for the incoming iPhone cancellation change. Actual
Redmi-to-iPhone cancellation remains an owner acceptance check, not something
established by simulator tests.

Practice level switching also stops sending the previous exposure ID to Next.
The existing backend resumes the unfinished exercise for the requested level,
including its stored choice order, and refreshes signed audio URLs. In-session
feedback and translation visibility are retained per level and cleared on an
account/language change. Explicit Next still finishes the current exercise. No
additional audio collection or backend/database change is needed.

Word explanations now record the originating tab before opening the shared AI
conversation. Back restores Practice unless the learner explicitly chose another
tab in the meantime. Reopening an existing AI route waits for its actual close,
so return navigation does not run prematurely or create a duplicate session.

Follow-up verification: 44 focused Flutter tests and 12 native iOS simulator
regressions passed. The broader Practice suite had five golden-image mismatches;
all five reproduced with identical pixel counts on untouched HEAD, so their
baselines were not rewritten. The debug and release builds succeeded. Version
3.31.2 (500) was signed with the existing Lisen Huang development profiles and
installed without launching or testing the physical iPhone. API 1.50.1 and website
0.25.1 were rechecked publicly; no further deployment was necessary. No commits,
pushes or store submissions were made.
