# App (`app/`) — agent notes

## iOS minimum

- **Deployment target:** **iOS 18.0** (`IPHONEOS_DEPLOYMENT_TARGET`, CocoaPods `platform`, and Pod `post_install` alignment).
- **Policy:** Do **not** maintain compatibility for **iOS &lt; 18.0**. It is acceptable to use APIs and patterns that assume 18.0+ without fallback for older OS versions.

## Locales

- **Taiwan Chinese (`zh-TW`):** Hidden only for **Learning language** flows (`fetchSupportedLocales(excludeZhTwForLearning: true)`, and the learning picker on edit profile). **Native language** selection uses the full locale list (including `zh-TW` when available from the native/API list).

## Version bumps

Every time any code is modified in this codebase, bump **both** the version name and build number in `pubspec.yaml`:

```
version: 1.2.1+112  →  version: 1.2.2+113
```

- Increment the patch segment of the version name (third number)
- Increment the build number (number after `+`)
- Do this as part of the same edit batch — not only before commits
- After changing the version, run `flutter build ios --debug --no-codesign` so `ios/Flutter/Generated.xcconfig` is regenerated with the new version before opening Xcode
