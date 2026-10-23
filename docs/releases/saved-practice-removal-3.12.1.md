# Saved practice removal: 3.12.1 (443)

Saved rows have no play icon or always-visible removal icon. A physical
right-to-left swipe reveals Delete; even a full swipe never removes the item.
Tapping the row still opens Practice. Only one row's deletion action stays open.
An accessibility action also opens the confirmation without requiring a swipe.

Delete asks for confirmation and shows the selected cue. Removing from the
Practice overflow uses the same dialog. Cancel or dismiss leaves storage intact.
The top-right trash icon confirms clearing all saved practices for the current
account on this device. Its write is serialized and atomic, preserving other
accounts. The action is disabled when the collection is empty or a write/dialog
is in progress; identity is rechecked before any confirmed deletion.

Clear-all copy is translated into all 17 app locales. No backend or website
change required. 22 focused saved-practice, storage, callback and CallKit tests
passed, including full-swipe reveal, cancellation, confirmed deletion, clear-all
and account-isolated serialized storage. Targeted analysis clean and required
iOS debug build passed. Signed release build and signature verification passed.
Installed on Ethan's iPhone 17 Pro without launching; device inventory confirmed
version 3.12.1, build 443. Physical-device interaction testing is left to the user.
