# Practice matching and stable mic: 3.16.4 (456)

The backend is the authority for grading every submitted Practice transcript.
The app no longer rejects unclear local matches before the backend can evaluate
them. Raw transcripts and confidence hints are retained; this does not introduce
AI guessing or change genuine uncertainty into a correct answer.

Japanese clock numerals now use the existing number-normalization path for
explicit hour/minute/second counters: 三時 and 3時 compare equally, including
fullwidth digits. Kanji in names and ordinary words are preserved. Grading
protects clock-unit assignments and 午前/午後, so swapped hours/minutes and AM/PM
remain distinct. Mandarin and Cantonese regression cases continue to pass. The
app's difference display uses the same normalization, retaining original text.
App and backend share byte-identical matching fixtures for these cases.

Recording startup and recording retain the existing content above and below
the mic, including previous feedback and Next. Background translations and
pronunciation updates appear after recording ends. The mic hint stays visible,
and recording labels reserve a stable height. Controls in retained content are
noninteractive while recording. A scrolled-page test verifies unchanged mic
bounds and scroll extent through permission startup and background updates.

Validation: full app suite passed 904 tests before the last two extra clock
protection cases; the final 188 matching, difference, mic and mandatory
callback/CallKit tests passed with those cases. Backend: 1,151 passed with 21
optional integration skips. Website: 16 tests passed. Analysis had no errors or
warnings and the existing 44 informational notices. Debug iOS build passed.

Compatibility: backend 1.40.2 changes matching only; no new endpoint, schema,
environment variable or credential is needed beyond the already deployed
pronunciation feature. Existing published clients remain compatible. Deploy GO.

Final signed iOS build and strict deep signature verification passed. Installed
3.16.4 (456) on Ethan's iPhone 17 Pro and independently verified both installed
version fields. Installation only; real-device microphone and locked-screen
CallKit acceptance remain with the user.
