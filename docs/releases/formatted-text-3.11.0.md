# Formatted AI text beside natural speech: 3.11.0 (441)

Bantera AI can deliver Markdown through `display_formatted_text` while speaking
naturally. The chat renders that written answer, retaining the spoken transcript
separately for audio accounting and resume checkpoints. The formatted answer is
saved locally, survives completion/navigation/reopening, and is included in later
conversation context. A new formatted answer invalidates an older translation.
Malformed or oversized tool arguments leave previous content unchanged.

Headings, emphasis, lists, examples and horizontally scrollable tables use the
existing renderer on iPhone and Android. Markdown never executes HTML/code or
loads embedded image paths. Existing validated web links use the app browser;
image/video tools remain separate. Simple conversation can remain plain text.

Requires backend 1.38.0 to advertise the tool; older apps retain their existing
transcript path. No website change is required.

Validation: 67 focused Flutter tests and targeted analysis passed. The chat UI
test confirms the separately supplied written answer is rendered in place of the
spoken introduction. Debug iOS build passed. Backend tests and a real Google
Live tool-call/audio test passed; details are in the backend release note.

Backend 1.38.0 was published successfully as `bantera-20261023-2` and independently
verified through the public API after cleanup. Android debug assembly and signed
iOS release build passed. The iOS signature verified and device inventory confirms
3.11.0 (441) installed on Ethan's iPhone 17 Pro. Installation only: the app was
not launched or tested on the phone. Audible playback and locked-screen callback
acceptance remain for the user to check. No store submission or Git push was made.
