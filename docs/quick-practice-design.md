# Quick Practice, 19 October 2026

## Research and design decisions

Primary references inspected before implementation:
- Duolingo speaking exercises, including the pictured speech bubbles and dedicated microphone: https://blog.duolingo.com/covering-all-the-bases-duolingos-approach-to-speaking-skills/
- Babbel Speak's short realistic scenarios and low-pressure feedback: https://support.babbel.com/hc/en-us/articles/25875402999826-Babbel-Speak
- Speak's focused speaking cards, flexible repetition and supportive feedback: https://help.speak.com/en/articles/11966855-what-are-tutor-lessons

Original Bantera design: lavender conversation card, generous rounded reply cards, separate 48-point playback targets, a prominent circular microphone, subtle waveform motif, inline feedback and one next-exercise action. Uses existing purple/mint theme, supports dark mode, reduced motion, larger text and scrolling on small screens. No copied artwork. Text is always visible, as requested. Replies cannot be selected by tapping. Cue terminology replaces Q1/Q2. Level is never presented to the learner.

## First release

Reply-selection only. Audio uses the configured primary/fallback audio models and regional voice selection. On-device speech recognition feeds a deterministic local choice matcher. The backend rechecks the match against the stored answer without AI. Recording files are temporary and deleted after transcription; the backend stores attempt outcomes, not recordings or transcripts. Unclear speech does not count against difficulty; pronunciation coaching is deferred.

Backend owns difficulty per account and language: first clear result per distinct dialogue, 12-exercise windows, 10 successes promotes, 4 or fewer demotes. Promotion resets the evidence window; stale-level exercises cannot adjust a new level. Starting band A1, upper band C2. These are practice bands, not certification.

Pool: five candidates at a time, underused topics, eight recent examples, local fingerprint/character-trigram/semantic-signature checks, then ONE batch AI quality/originality review with five closest examples per candidate. No embedding service or per-item comparison call. The semantic signature and bounded review reduce paraphrases but do not guarantee semantic uniqueness. Unique database constraints guarantee exact duplicate protection and per-user seen exclusion. Within-batch checks also apply. Generate audio only for approved candidates. No automatic generation retry loop; failures have a cooldown. Unseen ready material is served first; initial material becomes visible as each exercise's three audio clips are ready.

## Release compatibility

Additive API routes and four new tables. Published clients keep their existing contracts. No new secret or model setting required. New app gates requests through the existing account-scoped AI consent flow. Recording/playback stops when leaving the tab, backgrounding, or receiving a call. Existing callback regression suite remains mandatory; real locked-screen call audio is not proven by these tests.

## Daily word goals

Practice credits estimated listening words as audio plays (including intentional replays), and recognised spoken words once per recording, even when the chosen reply is incorrect. Both feed the existing account/language ledger. The global shell observes the same ledger for every feature. Once both daily targets are reached it presents a purple/mint completion-ring celebration with real totals, once per account per local day. Recording, assessment, playback and calls defer the presentation until safe. Reduced motion and large text are supported.

Following Apple's review guidance (https://developer.apple.com/documentation/storekit/requesting-app-store-reviews), the achievement is a custom celebration, not a custom rating gate. After it closes, the existing native StoreKit review request is eligible without lesson-count requirements, retaining the 90-day device cooldown. Apple controls whether its prompt appears. No star preference, reward, forced review, or claim to know whether a review was submitted.

## Single-speaker audio correction (2.20.1 / API 1.22.1)

A production clip displayed “Hi, I'm Mia. What's your name?” but its transcription
included an invented second speaker replying with a name. Practice had reused the
multi-speaker Discover TTS configuration. Practice now uses a dedicated single-voice
request per displayed utterance, including fallback models. Structured TTS receives
verbatim text and separate style metadata; older preview models receive explicit
read-once instructions without speaker labels. Regional voice selection remains.
This follows Google's [single-speaker TTS format](https://ai.google.dev/gemini-api/docs/generate-content/speech-generation).

Generation and batch review require one speaking turn per cue or choice and reject
self-answered questions. Content format version 2 excludes older material from
selection and resumption. Retired answers refresh the app instead of requesting a
retry on obsolete material. The authorized cleanup removes old Practice dialogues,
associated exposures/attempts, and their audio, preserving learned levels and word
totals. The old difficulty evidence window is cleared because the flawed audio could
have influenced it. No per-clip AI validation call was added to normal generation;
release checks transcribe a new cue and its two choices as a targeted regression check.


## Answer matching without AI (2.20.2 / API 1.22.2)

No answer-verification AI call or fallback remains. After native speech recognition,
the phone matches against both displayed choices; an uncertain result immediately
shows the existing neutral retry state without a verification request. Clear matches
use the existing authenticated endpoint, which independently runs the same rules,
checks the stored correct answer, and saves the existing idempotent attempt/progress.
Older app versions sending transcripts also receive deterministic verification.

The matcher normalizes case, punctuation, full-width ASCII, common English
contractions and English numbers from zero to ninety-nine. English hesitation words
are ignored. It permits one internal character recognition error in a long word
within an otherwise complete multiword phrase. Short answers, numbers, word additions
and omissions, word endings and scripts without stable spaces stay conservative.
Low confidence on distinguishing words and ambiguous ties return unclear. Free-form
paraphrases may need a retry: this feature asks learners to say a displayed reply,
and no semantic guess is made. The phone and server use the same forty regression
fixtures to prevent drift. No content reset, schema migration or new settings are
needed. AI still generates and quality-checks shared exercises and their audio.

## Visible transcript feedback (2.20.3)

Practice keeps the recognizer's exact text after unclear matches and verification
failures, labels it “What we heard”, and brings feedback into view after recording.
An empty result gets an explicit no-transcript state. Amber highlights plus underlines
show differing or uncertain words; missing words appear in a separate reference
reply, never inserted into the transcript. A clear closest reply can be used for
comparison, but an ambiguous or unrelated transcript does not get a guessed target.
An explicitly matched wrong choice is compared against the choice actually spoken,
so choosing the wrong reply is not described as a pronunciation failure.

The original UI uses a readable transcript card and a short reference line, informed
by [ELSA's word-level feedback examples](https://blog.elsaspeak.com/en/advantage-of-elsa-feedback/).
Our feature compares text and recognition confidence locally; it does not measure
phonemes, stress or intonation or prove a pronunciation error. This distinction is
visible in the feedback copy. All interface languages include the new labels.
Grapheme-aware comparison supports scripts without spaces, and reference/transcript
text honours right-to-left learning languages. No additional AI call or backend
change is required. Temporary recordings still follow the existing cleanup policy.

## Tolerant choice identification (2.20.4 / API 1.22.3)

The two real-phone ticket-desk transcripts now identify the selected reply despite
recognition substitutions, omissions and merged words. Literal matches and the
existing narrow spelling rule remain available for short replies. Longer replies
use ordered token overlap (twice the longest common subsequence divided by the two
lengths), at least 60%, and a 20-percentage-point lead over the other option. The
matcher additionally requires 55% target coverage and 60% transcript coverage,
with at least three matched words (six grapheme clusters for compact scripts).
Fuzzy targets must contain at least four words or seven compact-script clusters.

Uncertain words no longer veto an otherwise clear long reply. After excluding
those spans, at least 50% reliable overlap, a 15-point lead and the same minimum
match count must remain. Numbers and common negation markers remain conservative;
this is bounded text matching, not universal semantic equivalence. Saying both
complete choices, only a letter, a short fragment or unrelated text cannot pass.
The stored answer still determines correct versus incorrect, independently of
choice recognition. Transcript highlighting remains separate, including on success.

App and server share 70 fixtures covering both screenshots, both option orders,
correct/incorrect choices, confidence, ambiguity, negation, numbers and scripts
including Chinese, Japanese, Korean, Thai and Arabic. No AI verification call,
schema migration, content reset or new environment setting is required.

## Visible exercise level (2.20.5 / API 1.22.4)

The user's revised preference makes the existing A1–C2 exercise level visible.
A small outlined lavender badge sits beside the Practice title and displays only
the code. It follows the displayed dialogue, including resumed or buffered material,
rather than announcing a new level while an older exercise is still on screen.
The automatic progression rules remain unchanged. Missing or unfamiliar codes from
an older API do not create a guessed level or prevent practice.

The API adds a string `level` to ready exercise responses using the existing
stored dialogue level. Older clients ignore it; no schema or settings change is
required. The layout was checked in light/dark mode and with large text on a small
screen. Research reference: [Babbel's course-level presentation](https://support.babbel.com/hc/en-gb/articles/205600508-Available-languages).

## Level explanation link (2.20.6)

A text link at the bottom of Practice opens a scrollable help sheet. It explains
that each language starts at A1, the latest 12 scored exercises at the current
level control progression (10–12 correct up, 5–9 stay, 0–4 down), only the first
clear answer per exercise counts, unclear/skipped exercises do not count, and a
level change starts a fresh window. The A1/C2 bounds are explicit. This documents
the existing backend rules without changing progression or adding network calls.

All 17 app languages include the explanation. The sheet has a close button, drag
handle, screen-reader heading and wrapping level chips; content scrolls on small
screens and with large text. Opening/closing retains the current exercise. The link
is disabled while recording/checking an answer. Research: [Apple's sheet guidance](https://developer.apple.com/design/human-interface-guidelines/sheets),
used for a focused explanation that returns directly to Practice.

Verification: 109 Flutter checks passed, including callback/CallKit regressions,
help navigation and large-text layout; debug and signed release iOS builds and
signature verification passed. CoreDevice confirmed **2.20.6 (377)** installed and
successfully launched on the iPhone 17 Pro. Physical locked-screen callback audio
remains unverified. Backend remains **1.22.4**; no deployment was needed.

## Practice playback and skipping (2.20.7)

Opening/reopening Practice and resuming the app are silent. Only an explicit
Next action arms Cue 1 autoplay; that intent survives generation polling but is
cancelled on tab exit, backgrounding, calls, consent/profile changes, or manual
playback. A retired-material refresh remains silent. Pending playback also has a
generation guard so downloads cannot start audio after cancellation or a newer
play/record action.

Next asks for confirmation if the current feedback is unanswered, unclear, or
incorrect. Cancel retains the exercise and feedback; a correct answer advances
without a dialog. The confirmation uses short, specific actions in all supported
UI languages. The preparation subtitle has been removed. Reference:
[Apple alerts](https://developer.apple.com/design/human-interface-guidelines/alerts).

All three clips preload as soon as an exercise arrives, without activating an
audio session or counting listening words. Play and waveform extraction share the
same in-flight download. Completed downloads play from local files; failed
preloads remain retryable and playback can fall back to streaming. A small loading
indicator handles taps before a download finishes. Per-exercise temporary files
are removed when replaced/disposed; downloads have a deadline and size cap.
Cue 1 reuses ChatAudioWaveform, with real extracted peaks and playback-position
colour progress. Its fallback is an ordinary progress track if extraction fails.

Research follow-up: adaptation is supported by
[Duolingo's adaptive lesson design](https://blog.duolingo.com/keeping-you-at-the-frontier-of-learning-with-adaptive-lessons/)
and [item-response research](https://research.duolingo.com/papers/mccarthy.emnlp21.pdf),
but neither validates our specific 12-result thresholds. These remain product
heuristics for selecting practice difficulty, not an overall CEFR proficiency
assessment. [CEFR](https://www.coe.int/en/web/portfolio/self-assessment-grid)
covers listening, reading, spoken interaction/production and writing. No
progression algorithm was changed in this update.

The Hong Kong example was checked against the
[Education University of Hong Kong introduction lesson](https://corpus.eduhk.hk/cantonese/eng/dialogue/self_1.html)
and [Open Cantonese Lesson 1](https://opencantonese.org/books/cantonese-life-1/unit-1/lesson-1/print-or-export).
Both 我叫 and 我係 are valid introductions; 我叫 is not evidence of Mandarin
contamination. The existing generator already includes SpokenCantoneseInstruction
at every CEFR level, requiring natural Cantonese rather than Mandarin/written
Chinese simplification. No content deletion, prompt change or backend deployment
was warranted from this screenshot. Audio pronunciation cannot be assessed from
an image.

Validation: 132 checks passed, covering skip/cancel/advance, silent-entry and
cancelled-autoplay intent, shared audio downloads, failed-download retry and
cleanup, waveform extraction, matching, layouts and required callback/CallKit/
audio regressions. Analysis is clean; debug iOS build passed. Physical
locked-screen callback audio remains unverified; installation is not permission
for that acceptance test.

## Daily-goal header (2.21.0)

Practice is centred between equal-width side areas. The left control is a purple
ring with a locale-formatted percentage at one decimal place, or a prominent
Set goal button when no nonzero goal exists. The right area retains the exercise
level and completed-round count. The ring/button opens the existing daily-goal
settings, stops playback and cancels pending autoplay; returning stays silent.
Large accessibility text moves the centred title to its own row rather than
shrinking it or overlapping the controls. Setup text is translated in all app UI
languages, with tooltip and screen-reader labels.

The ring reads WordActivityNotifier for today's current learning language,
matching Profile and the existing goal celebration across Practice/Discover/Chats.
It updates on word records, settings changes, account/language switches and the
existing midnight refresh. Each listening/speaking contribution is capped at its
own target before dividing by the combined word target, so extra activity in one
skill cannot hide the other. Incomplete progress is capped at 99.9% for display,
preventing rounding to a false 100.0%; completed goals get a green ring.

Design research: [Apple's goal rings](https://www.apple.com/uk/watch/close-your-rings/)
for at-a-glance daily progress, and
[determinate progress guidance](https://developer.apple.com/design/human-interface-guidelines/progress-indicators)
for a stable track with an exact value. Bantera uses one ring, its own colours and
existing goal settings rather than introducing another setup flow.

The combined feature and regression suite passed 169 tests before the additional
ring capture test. Analysis is clean. No backend change or deployment is required.

The additional light/dark ring capture test passed (170 distinct checks across
these runs). The centred layout and 10.1% display were visually inspected; setup,
ring navigation, 0.0%, 99.9% and 100.0%, single-skill goals and large German text
were checked. The final debug iOS build passed. The 2.20.7 build was superseded by
2.21.0 before installation so the phone will receive all requested changes together.

Final release verification: signed iOS build 2.21.0 (379) passed codesign checks.
CoreDevice confirmed installation of 2.21.0 (379) and successfully launched Bantera
on Ethan's iPhone 17 Pro. No production backend/website changes, App Store submission,
Git commit or push were performed. Physical locked-screen callback audio remains
unverified.

## Compact header (2.21.1)

The user's refinement reduces the daily-goal control to a standard 48-point
button target with a thinner ring, preserving the one-decimal percentage. Both
goal states and the level/rounds area fit inside a fixed 48-point bar. Equal side
slots keep Practice centred; constrained content scales down rather than adding
another header row. Goal calculations and level scoring are unchanged.

Analysis and 42 existing Practice UI/callback/CallKit checks passed. Light/dark
captures were refreshed and the compact ring was visually inspected.

Debug and signed release builds passed; signature verification passed. CoreDevice
confirmed 2.21.1 (380) installed and launched on the iPhone 17 Pro. The device was
initially locked but became available before launch. No backend deployment was
needed. Physical locked-screen callback audio remains unverified.

## Always-visible on-device translations (2.22.0)

Cue 1 and both reply choices show a persistent secondary line in 13-point grey
text, with normal accessibility scaling and wrapping. Translation runs automatically
as one batch through the existing bantera/translation native bridge: Apple
Translation on iOS and ML Kit on Android. There is no backend/LLM translation
request or cloud-provider fallback. The saved translation language is preferred,
then native language, then UI language if neither profile field is set.

Translations are retained for the current exercise, invalidated on exercise or
language/account changes, and protected from late asynchronous results. New
translation work and model preparation wait until Practice is foreground and no
call, recording, answer submission or settings/confirmation flow is active.
Language models can use the phone's existing preparation/download flow. Failed or
unsupported pairs show a localised unavailable line and a retry action. Cantonese
is passed as yue-HK rather than silently requesting Mandarin; actual availability
is decided by the phone. Matching English regional variants reuse the source
text without an unsupported same-language translation request. Chinese script
variants remain distinct.

Reference: [Apple Translation](https://developer.apple.com/documentation/translation/)
for native translation and language availability. Existing subtitle styling was
adapted to inline secondary text, always visible with no toggle. The compact header,
original-text audio and answer matching remain unchanged. Translated words are
not counted as listening/speaking activity.

Analysis is clean. 59 checks passed, including the three-line native batch,
asset preparation/retry, stale results, foreground gating, language selection,
unsupported pairs, visible translations, layout and callback/CallKit/audio
regressions. Light/dark captures were updated and the inline layout inspected.
Physical locked-screen callback audio remains unverified.

The debug and signed release builds succeeded. Version 2.22.0 (381) was verified
installed on the connected iPhone 17 Pro and launched successfully with devicectl.
Actual translation output on the physical device remains to be checked by the
user. No backend deployment was required.

## Skip confirmation route timing (2.22.1)

MainScaffold marks Practice inactive while the skip dialog covers its route.
The dialog result completes before the parent rebuild restores the active flag,
so the previous immediate guard cancelled the confirmed skip. After confirmation,
Practice now waits for that frame before checking activity, account epoch and
exercise identity and advancing. The guards still reject stale actions.

A widget regression reproduces MainScaffold's route observer and parent rebuild:
it failed with the old timing and passes with the fix. All 144 Practice, matching,
audio-cache, callback, CallKit and audio regression tests passed. Analysis of the
changed screen and test is clean; whole-project analysis reports existing
informational lints elsewhere. Physical locked-screen callback audio is unverified.

Debug and signed release builds passed. Version 2.22.1 (382) was verified installed
on the iPhone 17 Pro. The initial launch attempt was rejected because the phone
was locked; after unlocking, devicectl confirmed a successful launch. No backend
changes or deployment were needed. The skip interaction itself was verified in
the regression test, not by operating the physical phone UI.

## Optional translation and level scoring (2.23.0)

Translation is hidden until the learner taps the small Show translation link
between Cue 1 and Cue 2. A short explanation appears before tapping; afterwards
the screen says this exercise will not change the learner's level. The three
native translations then appear in the existing small grey style. No translation
work starts before requesting the hint. How levels work explains the exclusion
and that an unassisted first clear result counts when advancing to the next
exercise. Daily listening and speaking words still count.

The phone persists assistance through the backend before revealing text. For new
clients, first clear results are saved but level changes are deferred until Next.
This allows translation revealed after either a correct or wrong answer to exclude
the entire exercise, without needing to reverse an earlier level change. Hint use
survives resuming or restarting the app. An already-scored legacy exercise is
finished on upgrading and replaced; its historical result is preserved. Old clients
keep their immediate-scoring contract. No AI translation or judgement is added.

Design reference: [Duolingo's immersion exercises](https://blog.duolingo.com/new-immersion-exercises-maximize-your-language-learning/)
shows how exercises can focus on meaning without relying on translation. Our
optional link and explicit scoring note are designed for Bantera; the particular
exclusion rule is the user's product decision, not a validated CEFR assessment.

145 app tests and 938 backend tests passed (14 existing backend skips). Checks
cover hidden/revealed captions, resumed assistance, reveal before/after answers,
first-clear scoring, idempotent completion, legacy scoring and call regressions.
Changed-file analysis and debug/release builds passed. Updated light/dark layouts
were captured and the light layout inspected. Physical locked-screen callback
audio remains unverified.

Optional-translation release follow-up: backend 1.23.0 was deployed successfully
and both public domains verified. App 2.23.0 (383) was verified installed on the
iPhone 17 Pro. Initial automatic launch was blocked by the phone lock.
After unlocking, CoreDevice confirmed a successful launch.

## Dialogues tab label and icon (2.23.1)

The second tab and its page title use Dialogues, with equivalent labels across
all 17 app languages. The compass is replaced by Cupertino's two speech bubbles
(outlined when inactive, filled when selected), distinct from Chats' single text
bubble. Navigation, content and backend contracts remain unchanged. Reference:
[Apple's tab bar guidance](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
on meaningful symbols paired with descriptive labels.

35 existing layout, callback and CallKit checks passed. Light/dark captures were
updated and the new tab icon/label visually inspected. Changed-file analysis is
clean. Physical locked-screen callback audio remains unverified.

## Fixed Practice toolbar (2.23.2)

Practice now uses Scaffold's fixed AppBar slot with the same 56-point standard
toolbar height and theme as Dialogues, Chats and Profile. The 48-point goal button
stays compact, the title stays centred, and the level badge/checkmark/count share
one horizontal row. Only the exercise body scrolls. The following update replaces
the session counter with the user's chosen persistent daily count.

52 existing and regression checks passed, including fixed position while scrolling,
toolbar height, horizontal alignment, small-screen/large-text layout and required
callback/CallKit tests. Changed-file analysis is clean. The header light/dark
captures were updated and the light capture inspected.

## Daily completions and global celebration (2.24.0)

The checkmark now shows today's correctly completed exercises, including assisted
answers, for the current account and learning language on this phone. Each
exercise counts once, immediately after a correct result. The count survives
restarts, resets at local midnight and remains visible at zero. Accents of the
same language share a count; Cantonese and Mandarin remain separate. This
activity counter does not change the stricter unassisted level-scoring rules.

The daily goal dialog opens on the root navigator over any ordinary app page.
Continuous word updates no longer reset its scheduling delay. Calls, recordings,
background state and another open modal defer presentation until it is safe.
The once-per-account/local-day guard and existing native review eligibility stay
in place. The operating system still decides whether to display its review prompt.

A silent two-sided confetti burst uses Bantera purple, teal, gold and pink, with
full-screen rendering above the dialog. Emission lasts 700 ms; particles are
removed after four seconds. The overlay ignores touches and accessibility
semantics. Reduce Motion suppresses particles, and backgrounding stops the effect
without replaying it on resume. No audio session or CallKit behavior is changed.

Research: [Flutter confetti 0.8.0](https://pub.dev/packages/confetti) provides a
small MIT-licensed canvas implementation, directional emitters and bounded
particle emission. [Apple motion guidance](https://developer.apple.com/design/human-interface-guidelines/motion)
informs the short duration and Reduce Motion support. This is an original
Bantera treatment using those primitives.

83 targeted tests passed, covering persistent counts, local midnight, account and
language isolation, retry deduplication, root-page presentation, touch pass-through,
Reduce Motion, effect cleanup, Practice layout and callback/audio regressions.
Physical locked-screen callback audio remains unverified.

## Waveform, translation confirmation and number matching (2.24.1, included in 2.25.0)

The decoded waveform previously received zero width inside Cue 1's loose Column,
so the real peaks disappeared after loading. The shared waveform now fills its
available width; Practice additionally interpolates real playback progress over
180 ms. A regression test decodes a real WAV fixture and checks the painted size
and intermediate progress. Chat controls remain aligned. No fake amplitude or
new audio playback is introduced.

Show translation now opens a confirmation using the localized exclusion text.
Cancel leaves assistance untouched. Confirmation waits for route coverage to
clear, persists the server exclusion, then reveals phone translations. The level
help link now ends with a question mark in all UI languages.

Phone and backend normalize Chinese integers through thousands, decimal amounts,
well-formed grouping separators and local currency notation. Examples include
$300 / 三百元 in Taiwan, $30 / 三十蚊 in Hong Kong, and 5分鐘 / 五分鐘.
Larger units and ambiguous colloquial shorthand remain literal; this is not
universal number-language parsing. Explicit foreign currencies, unequal amounts,
negation and uncertain contrasting numbers remain protected. Exact Chinese or
Cantonese replies can pass despite a low-confidence phrase when the alternatives
are sufficiently different and some reliable speech remains. Entirely uncertain
speech and near-identical alternatives retain retry behavior. Raw transcription
remains visible, with no AI judge.

Shared fixtures include all four supplied screenshots plus wrong amounts,
decimals, currencies, negative values, uncertain contrasts and negation omissions.
960 backend tests passed (14 existing skips), plus 190 focused app tests.
The candidate authenticated endpoint passed 22 new cases. Existing API contracts
remain unchanged; no database migration or new environment setting is required.

## Spoken-word credit flight (2.25.0)

When recognized speech contributes words and a daily goal is configured, sixteen
small purple/teal/gold fragments follow a curved path from the actual microphone
button to the fixed goal circle. A subtle arrival ring completes the 850 ms
flight; then the real word credit is applied and the circle/one-decimal percentage
interpolate together for 600 ms. Completion at 100% remains capped per goal;
reaching the listening target alone cannot mask missing speaking words. Empty
recognition and missing goals do not invent progress.

The overlay ignores touches, uses no audio resources and is excluded from screen
reader semantics. Reduce Motion skips travel and interpolation. Leaving Practice,
backgrounding, calls or disposal cancel the decoration without hanging the credit
future; a 950 ms fallback also prevents a suppressed ticker from delaying credit.
Three motion tests verify flight endpoints, arrival-before-increment sequencing,
intermediate percentage, Reduce Motion and idempotent cancellation. Callback,
CallKit and relevant audio regression tests passed; physical locked-screen callback
audio and live microphone acceptance remain unverified.

Design reference: [Apple's motion guidance](https://developer.apple.com/design/human-interface-guidelines/motion)
recommends brief, precise feedback that explains state changes. Bantera's original
particle path visually connects spoken practice to the existing goal control.

Release follow-up: signed app **2.25.0 (388)** passed code-signature validation,
was verified in CoreDevice's installed-app inventory and launched successfully
on the iPhone 17 Pro. Debug and release builds passed; targeted analysis is clean.
190 app regression tests plus three credit-flight tests passed. Backend **1.23.1**
is deployed and both public domains verified. Physical microphone interaction and
locked-screen callback audio remain unverified by the agent.

## Slower credit flight and rocket launch (2.25.1)

The credit sequence now uses a 1,600 ms particle flight, followed by a 900 ms
upward rocket animation from the goal circle, followed by an 800 ms ring and
percentage increase. The compact purple rocket has teal fins/window and warm
exhaust; it fades while lifting off. The total travel/launch overlay is 2,500 ms
with a 2,700 ms cancellation fallback. Credit is still released once when finished
or interrupted, and Reduce Motion skips the decorative sequence.

The timing regression test now verifies that the percentage remains unchanged
both midway through the slower flight and midway through the rocket launch,
then interpolates after arrival. 36 targeted layout/motion/callback/audio tests
passed and changed-file analysis is clean. The design continues to follow
[Apple motion guidance](https://developer.apple.com/design/human-interface-guidelines/motion)
for purposeful feedback and accessibility. This app-only update needs no backend
deployment. Physical microphone and locked-screen callback checks remain unverified.

2.25.1 release verification: debug and signed release builds passed, signature
verified, and CoreDevice confirmed **2.25.1 (389)** installed and successfully
launched on the iPhone 17 Pro. Rocket render frames were visually inspected in
light and dark mode. No backend deployment, Git commit/push or App Store
submission occurred.

## Correct-answer celebration and ahead preparation (2.25.2)

Only a server-confirmed correct answer plays the particle flight and rocket.
Incorrect or unclear replies update daily progress without that celebration.
Every recognized speaking attempt still receives word credit, including retries
and answer-request failures; the credit is recorded once in submission cleanup.
Listening credit is unchanged. Credit retains the captured account/language and
still completes if the decorative overlay is cancelled. Daily-goal completion
continues to celebrate reaching the goal regardless of answer correctness.

72 focused Practice, callback, CallKit and audio regression tests passed; targeted
analysis, debug/release builds and code-signature verification passed. App
**2.25.2 (390)** was verified installed and launched on iPhone 17 Pro. Physical
microphone interaction and locked-screen callback audio remain unverified.

Backend **1.23.2** targets eight unseen, fully voiced exercises per requested pool,
refilling while an exercise is displayed or answered. From eight scored results,
it also prepares reachable adjacent levels over the next four results, including
a projected deferred answer, without changing the actual score or seen history.
Two pool consumers allow independent text preparation. Speech requests are
serialized within the worker to avoid provider-limit bursts; approved drafts and
completed clips are saved and resumed after temporary failures. Database locks prevent concurrent
replicas from generating the same pool. Preparation is bounded to two batches
per demand and existing duplicate checks and provider fallbacks remain intact.
First use of an empty pool, provider delays, or rapid skipping can still require
a wait; preparation does not guarantee instant availability in every case.

Backend deployment follow-up: **1.23.2** is live through release
`bantera-20261020-3`; both public domains passed checks (128/128 HTTP 200 samples).
967 backend tests passed. The staged API verified early next-level text generation,
no early scoring/seen exposure, and an immediately ready cached B1-to-B2 transition
with three playable audio URLs. Fresh next-level audio could not finish during the
live test because eligible speech providers were quota-limited. This remains an
external availability limitation, not a guarantee that every Next is immediate.

## Simplified Practice header (2.25.3)

The completed-practice checkmark and number are removed from the header. The
level badge is on the left, Practice remains geometrically centred, and the
48-point daily-goal circle (or Set goal control) is on the right. The fixed toolbar
remains 56 points high. Its shared goal anchor moves with the control, so the
existing correct-answer particles and rocket use the new destination. Completion
history still persists; this change removes its header display only.

Design reference reviewed: [Apple toolbar guidance](https://developer.apple.com/design/human-interface-guidelines/toolbars).
Light/dark captures and the no-goal layout were visually inspected. Updated
existing layout/golden checks passed, including narrow-screen large-text layouts;
62 focused Practice/callback/CallKit tests passed and changed-file analysis is
clean. Physical locked-screen callback audio remains unverified. No backend
change or deployment is needed.

The same **2.25.3 (391)** update moves Profile's practice library links to a
rightmost horizontal-ellipsis menu in Dialogues. Its three localized entries are
Practice History, Saved Media and Saved Cues, in that order, with familiar icons
and existing destinations. The adjacent add action remains available. Profile no
longer loads or subscribes to saved-content/history data just to show these links;
each destination continues to load its own data. The menu follows the existing
Material popup behavior, with a 16-point corner radius and wrapped labels.
Reference: [Apple pull-down button guidance](https://developer.apple.com/design/human-interface-guidelines/pull-down-buttons).

Final app checks: 82 focused Practice/library/callback/CallKit tests passed,
changed-file analysis passed, debug/release builds and code signature passed.
CoreDevice confirmed **2.25.3 (391)** installed and successfully launched on
iPhone 17 Pro. No App Store submission or Git commit/push was performed.

Android release APK **2.25.3 (391)** was also built using `flutter build apk --release`.
`apksigner verify` passed with the Bantera upload certificate; APK metadata confirms
package `com.lisenhuang.bantera`, version 2.25.3 and build 391. The universal APK
is at `build/app/outputs/flutter-apk/app-release.apk`. Android installation/runtime
was not tested; this task produced the APK and an adb install command.

## Android recognition and avatar caching: 20 October 2026

App **2.25.5 (393)** adds shared persistent avatar caching: display cached bytes
first, revalidate in the background on entering Chats or refreshing, coalesce
requests, and retain the last good image when offline or when a response is
corrupt. Cache entries follow avatar URLs and account identities. Correct Practice
answers now show the particle/rocket celebration toward Set goal even without a
configured goal; no fictitious percentage is displayed and incorrect answers
remain unanimated.

English ASR formatting now accepts `$10` against `ten dollars` and `10:00`
against `ten o'clock`. Matching preserves distinctions between amounts, currencies,
negative values, decimals, AM/PM, and negation. Whole-hour normalization does not
claim support for all possible spoken time formats. Both phone and server use
identical shared fixtures. Existing Chinese/Cantonese cases remain covered.

Verification: 152 focused matcher/animation/cache/callback/CallKit/audio tests
passed; changed-file analysis passed; final iOS debug/release and Android release
builds passed. iOS code signature and Android Bantera upload signature verified.
CoreDevice installed and launched 2.25.5 (393) on iPhone 17 Pro. APK metadata
confirms com.lisenhuang.bantera, version 2.25.5 and versionCode 393. The universal
APK remains at build/app/outputs/flutter-apk/app-release.apk. Physical Android
runtime and locked-screen CallKit audio remain unverified; no App Store submission
or Git commit/push was performed.

New-account avatar investigation: Google login imports the Google profile photo
and intentionally skips generated-avatar gender selection when an avatar exists.
Android and iPhone share this flow. A temporary server-side account successfully
queued image generation (202), retrieved an 84,719-byte JPEG (200), and was deleted
through the account deletion endpoint (204), including its generated object.
This validates the backend generation/storage path, not physical-device signup.

## Reachable next action: 20 October 2026

App **2.25.6 (394)** pins a full-width, labelled Next practice action above the
tabs after a correct response. It occupies its own bottom action area, so feedback
remains scrollable and is not covered by an overlay. It replaces the successful
state's inline Next button, stays reachable at large text sizes, and disappears
when advancing. Pending/incorrect/unclear attempts retain the existing inline
Next action and skip confirmation. Recording, checking, route coverage and an
in-flight transition disable the pinned action; the existing transition guard
prevents duplicate advancement and retains next-cue autoplay.

Design references: Material's extended primary-action guidance
(https://github.com/material-components/material-web/blob/main/docs/components/fab.md)
and primary colour roles (https://m3.material.io/m3/pages/color-roles).
The adapted design uses a reserved bottom bar instead of covering learning content.

Verification: 20 Practice screen tests passed, including scrolling long feedback
at 320px/1.7x text, immediate no-scroll advancement, clearing the action on advance,
and preserving skip confirmations. Updated dark screenshot inspected. Analysis
passed; all 17 required callback/CallKit regression tests passed. No backend
change is required. Physical locked-screen callback audio remains unverified.

Final debug/release iOS and signed Android APK builds passed. CoreDevice confirmed
installation and successful launch of **2.25.6 (394)** on iPhone 17 Pro. APK
signature verification passed and package metadata confirms versionCode 394.
Android physical runtime was not exercised. No backend/website deployment,
Git commit/push or store submission was needed or performed for this UI update.

## Recording beside the replies: 20 October 2026

App **2.25.7 (395)** keeps the microphone and recording status directly after the
two Cue 2 choices in every answer state. Feedback, transcript comparison and
errors now follow the recording controls. Receiving feedback no longer scrolls
automatically away from the reply text. The successful pinned Next action remains.

Verification: all 24 Practice screen tests passed, including control order and
visibility with long correct/incorrect/unclear feedback; 17 callback/CallKit
regression tests passed. Changed-file analysis passed. Updated light transcript
layout visually inspected. No backend change is required. Physical locked-screen
callback audio remains unverified.

The 395 build was superseded before installation by the combined level-picker
and recording-replay release below.

## Level dropdown and recorded-answer replay: 20 October 2026

App **2.26.1 (397)** opens an anchored dropdown from the top-left level badge.
All six CEFR labels are visible. Levels above the current earned level are grey
with a lock, but tapping them opens an explanation. This uses the current level,
not the historical maximum: a former B2 is locked again after a drop to B1.
Choosing a lower level confirms review mode, saves the choice per account/language,
and preserves the earned level and scoring window. Returning to the earned level
restores normal scoring. Review answers never affect level changes. The menu
shows the earned level separately from the selected practice level, and the page
shows a review caption. Existing toolbar height and pinned successful Next remain.

The transcript card includes a 48px play/stop control on its right when a recorded
clip is available, including when transcription fails. It plays the original local
WAV using the same audio player and call/lifecycle guards as cue playback, so clips
do not overlap. No new audio upload or AI request is introduced. The clip is removed
on a successful new recording, advancement, account/language change, consent
revocation, or disposal. It is temporary and does not become a saved recording.
Recognized words heard during replay use the existing listening activity tracker.

Design references: Duolingo's separate review flow
(https://blog.duolingo.com/how-to-review-lessons-on-duolingo/), Material list states
(https://m3.material.io/components/lists/overview), Duolingo self-recording guidance
(https://blog.duolingo.com/improve-pronunciation-in-new-language-tips/) and Apple's
audio controls guidance
(https://developer.apple.com/design/human-interface-guidelines/playing-audio).
The adapted UI keeps selection in a compact anchored menu and playback beside
the actual transcript rather than adding another page or replacing source audio.

Verification: **86** focused Practice/cache/callback/CallKit/audio tests passed;
analysis passed. Tests cover menu locks/confirmations, preserved earned level,
recording-control position, replay/play-stop/disabled/loading states, absent clips,
empty transcripts, and a narrow multilingual transcript layout. Menu and microphone
layout goldens were inspected. Backend 1.25.0 adds persisted review state and an
opt-in API field so older clients retain their existing level/resume behavior.
Physical microphone replay and locked-screen CallKit audio are not established
by these automated tests.

Debug and signed release iOS builds passed. The signed **2.26.1 (397)** app was
verified, installed and successfully launched through CoreDevice on the connected
iPhone 17 Pro. This establishes installation/launch, not physical recording replay
or locked-screen callback audio. Backend 1.25.0 was deployed and independently
verified on both public domains (156/156 HTTP availability samples passed).

## Level help in the dropdown: 20 October 2026

App **2.26.2 (398)** moves “How levels work?” to a separated footer item beneath
C2 in the top-left level dropdown. The page's bottom link is removed. The existing
help sheet and scoring explanation are reused. Closing help preserves the current
exercise. The menu remains scrollable on smaller screens and with larger text.

All 32 Practice screen/header tests passed, including opening help from the menu,
returning to the unchanged exercise and narrow/large-text layouts. The updated
menu golden was inspected. No backend change or additional deployment is required.

The 17 required callback/CallKit tests and targeted analysis also passed. Debug
and signed release iOS builds passed; signature and version **2.26.2 (398)** were
verified. CoreDevice confirmed installation and launch on iPhone 17 Pro. Physical
recording playback and locked-screen callback audio remain unverified. No Git
commit/push or App Store submission was performed.

The release APK also built successfully. apksigner verification confirms the
Bantera signing certificate; package metadata is `com.lisenhuang.bantera`,
versionName **2.26.2**, versionCode **398**. Output:
`build/app/outputs/flutter-apk/app-release.apk`. Android physical runtime was not
tested. The website-hosted APK was not replaced.
