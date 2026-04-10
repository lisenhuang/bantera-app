# App (`app/`) — agent notes

## iOS minimum

- **Deployment target:** **iOS 15.8** (`IPHONEOS_DEPLOYMENT_TARGET`, CocoaPods `platform`, and Pod `post_install` alignment).
- **Policy:** Do **not** maintain compatibility for **iOS &lt; 15.8**. It is acceptable to use APIs and patterns that assume 15.8+ without fallback for older OS versions.

## Version bumps (repo-wide)

See the workspace root [`AGENTS.md`](../AGENTS.md) for `pubspec.yaml` / `Generated.xcconfig` rules before app commits.
