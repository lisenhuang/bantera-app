# App (`app/`) — agent notes

## Git commits

- **Do not run `git commit` (or `git push`) automatically.** Committing is a human task.
- Make and stage edits as needed, but leave the actual commit/push to the user — only commit if they explicitly ask you to in that request.

## Sync with remote before modifying code

- **Before making any code change, check GitHub for newer commits and pull them first.** Run, from this directory:

  ```
  git fetch origin
  git status -sb          # "behind N" means the remote has newer commits
  git pull --rebase       # only if behind
  ```

- Only start editing once the local branch is up to date with the remote.
- If the rebase conflicts or uncommitted local changes block it, stop and report to the user — do not force, reset, or stash without being asked.

## iOS minimum

- **Deployment target:** **iOS 18.0** (`IPHONEOS_DEPLOYMENT_TARGET`, CocoaPods `platform`, and Pod `post_install` alignment).
- **Policy:** Do **not** maintain compatibility for **iOS &lt; 18.0**. It is acceptable to use APIs and patterns that assume 18.0+ without fallback for older OS versions.

## Locales

- **Taiwan Chinese (`zh-TW`):** Hidden by default from both the **native** and **learning** pickers (onboarding and edit profile), and shown only once the user's IP is confirmed to be **outside mainland China**. `RegionService` (`lib/infrastructure/region_service.dart`) reads the country from Cloudflare's `https://api.bantera.app/cdn-cgi/trace` (`loc=XX`); a failed lookup keeps it hidden and is retried next time. `fetchNativeLanguageOptions` / `fetchLearningLanguageOptions` apply the filter. The check is app-only; the backend accepts `zh-TW` everywhere.

## Version bumps

Every time any code is modified in this codebase, bump **both** the version name and build number in `pubspec.yaml`:

```
version: 1.2.1+112  →  version: 1.2.2+113
```

- Increment the patch segment of the version name (third number)
- Increment the build number (number after `+`)
- Do this as part of the same edit batch — not only before commits
- After changing the version, run `flutter build ios --debug --no-codesign` so `ios/Flutter/Generated.xcconfig` is regenerated with the new version before opening Xcode

## Release build for Play Store (AAB)

To produce a signed bundle for the Play Store, just run (after the usual version bump):

```
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab` (upload this to Play Console).

- **Signing is automatic.** The release `signingConfig` in `android/app/build.gradle.kts` loads
  the upload key from **`android/key.properties`** (key alias `upload`, keystore
  `android/upload-keystore.jks`). No password needs to be entered at build time.
- **Secrets are gitignored and must stay that way.** `key.properties`, `*.jks`, and `*.keystore`
  are in `.gitignore`. **Never** commit the keystore or paste the keystore password into any
  tracked file (including this `CLAUDE.md`) — the password lives only in `android/key.properties`
  on the dev machine. To find/build, read that file; do not echo the password into git.
- **Play App Signing** is used: Google holds the app-signing key and re-signs for distribution;
  our keystore is only the *upload* key. The same upload key must be reused for every update
  (Google can reset it if lost).
- Play requires `versionCode` to increase each upload — it comes from the pubspec build number
  (the `+NNN`), so the standard version bump above covers it.
- Verify the bundle is signed with the upload key (not debug) via
  `keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab` → owner should be `CN=Bantera`.

## Publish Android to the website (direct APK download)

The marketing site (`../website`) hosts a downloadable APK (since the repos are private, this is
how testers/users get Android). To cut a new Android download:

1. Bump the version (see **Version bumps** above).
2. Run **`./scripts/publish_android.sh`** — it builds + signs the **arm64-v8a** release APK
   (signing from `android/key.properties`), copies it to `../website/public/bantera.apk`, and
   stamps the version into `../website/src/lib/android-release.ts` and
   `../website/public/android-release.json`.
3. In `../website`, commit + push `public/bantera.apk`, `public/android-release.json`,
   **and** `src/lib/android-release.ts`
   (the deploy serves the new APK and shows the new version on `/download`).

So "publish the Android app" = bump version + run the one script + push the website. arm64-v8a
(~36 MB) covers all modern phones; switch the script to a universal build only if you need the
rare 32-bit/x86 device.
