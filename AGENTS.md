# App (`app/`) — agent notes

## iOS minimum

- **Deployment target:** **iOS 15.8** (`IPHONEOS_DEPLOYMENT_TARGET`, CocoaPods `platform`, and Pod `post_install` alignment).
- **Policy:** Do **not** maintain compatibility for **iOS &lt; 15.8**. It is acceptable to use APIs and patterns that assume 15.8+ without fallback for older OS versions.

## Locales

- **Taiwan Chinese (`zh-TW`):** Hidden only for **Learning language** flows (`fetchSupportedLocales(excludeZhTwForLearning: true)`, and the learning picker on edit profile). **Native language** selection uses the full locale list (including `zh-TW` when available from the native/API list).

## Version bumps (repo-wide)

See the workspace root [`AGENTS.md`](../AGENTS.md) for `pubspec.yaml` / `Generated.xcconfig` rules before app commits.
