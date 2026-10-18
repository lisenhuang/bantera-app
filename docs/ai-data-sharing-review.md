# AI data sharing review, 2.18.5 (368)

Prepared for the 18 October 2026 rejection under 5.1.1(i) and 5.1.2(i).

## Behaviour

- Before opening AI chat, creating an AI lesson or generating an avatar, the app shows an explicit disclosure naming Google and Cloudflare, the data each receives, and the purpose. AI web/image search recipients are also disclosed.
- “Agree and continue” saves versioned permission for that account on that device. “Not now”, dismissal and Back do not grant permission. Existing users must consent; dismissing the old privacy banner does not count.
- AI HTTP and WebSocket clients independently check permission. Background conversation summaries and incoming AI callback acceptance cannot obtain new permission or bypass this check.
- Settings > AI data sharing displays the disclosure and allows withdrawal. Withdrawal stops active AI streams and prevents future requests on that device. Requests already sent may finish; existing scheduled reminders are managed and cancelled from the reminders link on that page.
- Normal practice, discovery, local translation and ordinary video uploads do not require AI consent.
- All 17 app locales include the new disclosure. User-facing provider copy uses Google. Internal model identifiers and endpoints are unchanged.

## Actual recipients

| Recipient | Data and purpose |
| --- | --- |
| Google | Voice audio, transcripts, user-attached images, prompts, relevant history and summaries, profile name/languages, learning level, practice and saved-learning context, requested vocabulary, clock/time zone, and reminder details for AI conversations, lessons, speech, summaries and reminders. |
| Cloudflare | Name, chosen avatar gender and languages for avatars; lesson title and language for generated covers. |
| Microsoft Bing, DuckDuckGo, Wikimedia Commons | Queries for AI-requested web/image searches. Results may be passed to Google. |

Google's paid and unpaid services have different data-use terms. The disclosure and policy do not promise paid-only processing, no human review, or universal zero retention. Production billing status for every configured Google key was not verified as part of this change. Review that configuration before making stronger privacy assurances.

## Reviewer verification

1. Sign in with a fresh account/device, or open Settings > AI data sharing and turn sharing off.
2. Open AI chat. Verify Google and Cloudflare are identified and the shared data and purposes are described before any chat context is sent.
3. Select “Not now”. AI chat does not start. Discovery and ordinary practice remain available.
4. Repeat and select “Agree and continue”. The requested AI feature can now proceed.
5. Restart and verify the choice persists for that account; a different account must consent separately.
6. Turn sharing off in Settings. An active AI conversation ends; attempting another AI action asks again. The settings page explains already-submitted work and provides access to scheduled reminders for cancellation.
7. Check AI lesson creation and avatar generation with sharing off; both ask before submitting.
8. Check the policy link at https://bantera.app/privacy#ai-services after publishing the website change.

## Release preparation

The app is version 2.18.5 (368); the website is 0.11.3. The privacy page source has been updated, but changing the source does not publish it.

Before resubmitting, publish the website change through the existing Oracle AU runbook, archive and upload the app from Xcode, select build 368, and include the verification steps above in App Review Information. Check the App Privacy answers against the disclosed categories. No App Review message, build upload, submission, commit, push or production deployment was performed by this task.

No backend code, database migration or server environment change is required for these client gates. Older installed app versions keep their existing behaviour; the new permission gate applies to this app release on each device.

## Validation completed

- Full Flutter suite: 479 tests passed.
- Consent UI: phone, iPad, 200% text, dismissal and explicit acceptance checks passed. The policy link remains reachable by scrolling.
- iOS debug build without signing: passed; generated build name/number are 2.18.5 / 368.
- Flutter analyzer: no errors or warnings; 42 existing informational lint notices remain.
- Website privacy-page ESLint, TypeScript check and production build: passed. The available local Node runtime is 25.2.1; package.json specifies Node 24.
- No real user content was submitted to AI providers during these tests.

## References

- https://developer.apple.com/app-store/review/guidelines/#data-use-and-sharing
- https://ai.google.dev/gemini-api/terms
- https://developers.cloudflare.com/workers-ai/platform/data-usage/
