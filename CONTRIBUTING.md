# Contributing

This repository is maintained by [@lisenhuang](https://github.com/lisenhuang). Keep changes focused and explain the problem, the approach, and how you checked it. Discuss large changes in an issue before implementing them.

## Local checks

Use the toolchain versions declared by the CI workflow and package files. From this repository root:

```sh
flutter pub get --enforce-lockfile
flutter analyze --no-pub --no-fatal-infos
flutter test --no-pub --coverage
flutter build apk --debug --no-pub
(cd android && ./gradlew testDebugUnitTest --no-daemon)
```

CI pins Flutter 3.41.9, restores `pubspec.lock`, fails on analyzer errors or warnings, runs all Flutter unit/widget tests with LCOV coverage, compiles an Android debug APK, and runs the native Kotlin tests. Analyzer informational lints remain visible but do not fail the build. Coverage is available as an artifact, not a claimed coverage target. iOS compilation and native audio behavior are separate checks; CI does not exercise a physical phone.

## Review expectations

- Add regression tests for fixes and new behavior. Prefer deterministic fixtures and mocked external services; never run tests against production data.
- Follow the surrounding code style. Keep type checking and lint rules enabled; explain any necessary local exception.
- Keep API contracts, persisted data and account boundaries compatible. Describe migrations and configuration changes explicitly.
- Include accessibility and localization checks for UI work, and screenshots when they help review.
- Update the README or relevant design documentation when behavior or setup changes. Follow the versioning rules in `CLAUDE.md`.
- Commit lockfile changes alongside dependency changes. Dependabot opens update proposals; updates still need review and passing checks.
- Do not include keys, tokens, recordings, personal data, or signing material in changes, test fixtures or CI logs. See [SECURITY.md](SECURITY.md).

## Continuous integration and delivery

[CI](.github/workflows/ci.yml) runs for pull requests to `main`, pushes to `main`, and manual dispatch. Action revisions are pinned; workflow tokens have read-only repository permissions. Test reports are retained for 14 days. The README badge links to the actual workflow result for `main`.

Passing checks are evidence for the checks listed above, not a guarantee of complete test coverage or production behavior. Document any skipped tests and manual verification. CODEOWNERS identifies the maintainer; it does not itself enforce branch protection or mandatory approval.

CI builds and tests only. Signing, store submission, and production deployment remain separate human-operated release steps.
