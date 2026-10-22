# Practice AI explanations and video search

Released locally to the requested iPhone on 22 October 2026: app **3.7.0 (431)**, with public backend **1.34.0**. Installation and installed version were verified. The physical app was not launched or tested. No App Store submission or Git push was performed for this batch.

## Behavior

App 3.8.2 (436) changes word selection to two taps. The first tap underlines
that exact word or CJK character; tapping the same underlined selection again
opens the existing explanation confirmation. Selecting another word moves the
single underline across Q1 and both Q2 choices without opening a dialog. New
exercises clear selection. Cancelling the dialog retains the underline, and no
AI request is sent until the user confirms. Speaker buttons remain independent.
The 74-test selection/Practice/callback/audio regression run passed; changed-file
analysis was clean. Unsigned debug and signed release iOS builds passed.
Version 3.8.2 (436) was installed without launching or testing the physical app.


The 3.7.1 (432) dialog refinement puts the selected word or character in the localized title, such as “Explain ‘broad’ with Bantera AI?”. The body contains only the original sentence, with the exact selected occurrence highlighted using the theme's container colors and bold text. Long content scrolls. The AI request and optional-image behavior remain unchanged.

The 3.7.2 (433) prompt refinement explicitly refers to the current saved Practice level already supplied by the backend, including easier review selection. The request now directs image search for concrete objects (for example, a passport), animals, places, and visually demonstrable actions in the sentence. Abstract, grammatical, and figurative meanings can still skip images. The transient search capability note recognizes this explicit conditional request without allowing automatic searches for unrelated ordinary questions. This changes the app prompt only; no backend or website release is needed.

Investigation of the reported missing passport image found a weak optional-image directive alongside strict explicit-search instructions. This can explain a skipped search, but the exact earlier model decision was not captured. A live local check through the actual `AiImageSearch` client fetched and decoded two images for `passport document cover` (28,148 and 35,859 bytes). This verifies the local search path, not the network conditions on the user's phone. The text-turn integration test now checks image delivery and persistence as well as spoken response and vocabulary consent. Model tool choice remains probabilistic; no claim is made that a live model always follows the instruction.

- Every word in Practice Q1 and both Q2 sentences is tappable. A confirmation shows the selection and full sentence; cancel sends nothing. Q2 cards no longer show the microphone reminder when tapped. Speaker buttons and spoken answers remain available.
- Confirming opens Bantera AI and sends text through the existing Live WebSocket, with spoken audio and captions returned. Requests remain account-scoped, are consumed once, and can be retried after failure.
- Chinese and Japanese character selections include the exact UTF-16 range and full sentence. The prompt asks AI to identify the surrounding word and explain the selected character's role. Korean and other languages also retain sentence context.
- Images are optional when helpful for the explanation. The prompt does not request videos. Vocabulary additions require a later explicit agreement; mutation tools are blocked during the initial explanation turn.
- The Live search tool separately supports explicitly requested videos. YouTube results have an on-demand inline player and an in-app browser fallback. Vimeo, Dailymotion, and TED results open in the browser. Results are metadata, not evidence that AI has watched a video.
- Web, image, and video searches execute on the phone using the existing search path. The backend relays tools.
- Text requests do not earn speaking credit. Explanation audio earns listening credit as playback progresses.
- Video players stop when covered, backgrounded, scrolled away, or superseded, and are disabled during calls, recording, and AI audio replies.

## Verification and remaining checks

Focused and regression Flutter tests passed, including callback/CallKit, audio route, call clock, Live interruptions, voice transport, consent, navigation, vocabulary tools, word selection, and video URL validation. Analysis reported no errors or warnings; existing informational findings remain. Unsigned iOS debug, signed iOS release, signature validation, and Android arm64 debug builds passed. iOS 15.0 remains the minimum.

On the Duo simulator, the real Practice UI showed a confirmation for `行` in `銀行在哪裡？`, including the full sentence. The inline YouTube player loaded its real thumbnail and controls. The browser fallback opened and visibly played the sample video. Inline playback itself was not fully verified because its play control was unavailable to UI automation. Open and closed Duo layouts were not both rechecked during this batch.

Actual production AI responses were not exercised with a paid provider request. Protocol and mocked integration tests passed. Physical locked-screen callback acceptance and two-way audio remain unverified and require the user's check; installation does not establish that behavior.

Simulator screenshots from this run: `/tmp/bantera-duo-video-closed.png` and `/tmp/bantera-duo-character-confirmation.png`. These temporary files are local evidence, not committed release assets.

## Implementation references

- [Google Live API](https://ai.google.dev/api/live.md)
- [Live tool use](https://ai.google.dev/gemini-api/docs/live-api/tools)
- [YouTube embedded player requirements](https://developers.google.com/youtube/terms/required-minimum-functionality)
- [YouTube IFrame API](https://developers.google.com/youtube/iframe_api_reference)

The YouTube player uses a package-based HTTPS origin/referrer, preserves native controls and branding, and keeps a browser fallback for unavailable embeds. Website code did not need changes.
