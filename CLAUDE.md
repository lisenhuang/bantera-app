# App Codebase Rules

## Version Bumping

Every time any code is modified in this codebase, bump **both** the version name and build number in `pubspec.yaml`:

```
version: 1.2.1+112  →  version: 1.2.2+113
```

- Increment the patch segment of the version name (third number)
- Increment the build number (number after `+`)
- Do this as part of the same edit batch — not only before commits
- After changing the version, run `flutter build ios --debug --no-codesign` so `ios/Flutter/Generated.xcconfig` is regenerated with the new version before opening Xcode
