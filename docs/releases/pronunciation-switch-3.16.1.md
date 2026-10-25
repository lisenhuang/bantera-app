# Pronunciation switch: 3.16.1 (453)

Replaces the selected Pronunciation pill with an adaptive on/off switch beside
Level. The iOS switch uses Bantera purple when enabled. The text label and switch
share accessibility semantics, and the row wraps with large text or narrow
screens. Existing account/language preferences, requests, readings and recording
behavior are unchanged. No backend or website deployment is required.

Validation: 32 pronunciation and required callback/CallKit regression tests
passed. The integration preview uses the actual Bantera theme and iOS control
style. It covers switch state, remembered preferences, delayed readings, stable
size, adjacent Level placement and wrapping at 320 points with 2x text. Analysis
has no errors/warnings and the existing 44 informational notices. Debug iOS build
passed.

Signed release build and deep strict signature verification passed. Installed
3.16.1 (453) on Ethan's iPhone 17 Pro and independently verified both installed
version fields. Installation only; the app was not launched on the phone.

## Alignment refinement: 3.16.2 (454)

Level now aligns with the left content edge and Pronunciation with the right
content edge, leaving flexible space between them. Existing wrapping remains
available for narrow screens and larger text. The 32 focused pronunciation and
mandatory callback/CallKit tests pass, including explicit left/right edge checks;
the iOS preview was visually reviewed. Debug build passed.
Signed release build and strict code-signature verification passed. Installed
3.16.2 (454) on Ethan's iPhone 17 Pro and verified the installed version fields.
The app was not launched on the phone.
