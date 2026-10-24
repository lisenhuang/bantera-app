# Practice improvements: 3.14.0 (446)

Practice's overflow menu ends with Change Translation Language on devices with
built-in translation support. It opens the source-specific supported-language
picker. A manual choice is stored separately from automatic fallbacks, per
account and learning language on this device, and takes priority over the native
language. Without a manual choice, the existing native-first fallback remains.

Cancel preserves the current translation. Changing the choice clears old results
and refreshes already-revealed translations. Choosing a language alone never
reveals translation or changes scoring; Show translation retains its existing
confirmation. Uninstalled language models retain their explanation and download
confirmation when translation is requested. Account/exercise changes invalidate
pending selections. iOS 15-17 keep the translation menu hidden.

Picker and celebration copy are translated into all 17 app UI languages. No
backend or website change is needed.

Earned level increases trigger a trophy dialog and full-screen confetti. Initial
loads, manual level choices and saved reviews do not trigger it. Confetti respects
Reduce Motion. Dismissing the celebration requests the native iOS rating prompt
through the existing review service, after the closing animation and only while
account, route, foreground and call guards remain safe. StoreKit controls whether
a prompt appears; no custom rating gate is shown.

Recorded iOS speech now requests intermediate results and preserves completed
utterances across an on-device recognizer reset after silence. Active hypotheses
remain replaceable, word confidences stay attached, and an empty final result
cannot erase earlier words. Existing on-device/network recognition policy and
recording limits remain unchanged. Simulator unit tests cover reset timestamps,
empty final results, cumulative corrections and disjoint absolute ranges. Real
speech-recognition accuracy during the user's pauses remains a device acceptance
check; no physical-device testing was performed.

Validation: 153 Flutter tests and two native iOS simulator speech regression tests
passed. Focused static analysis clean. Final unsigned debug and signed release builds
passed; strict code-signature verification passed. Installed on Ethan’s iPhone
17 Pro without launching; inventory confirmed 3.14.0 (446). No backend/website
deployment, store submission or Git push was performed.
