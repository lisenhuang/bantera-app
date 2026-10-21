# Speaking leaderboard

Design and implementation, 21 October 2026. Mockups use fictional names and sample counts, not customer data. Rendered from the Flutter components, with Bantera's actual light/dark themes. Goal mockups condense the existing daily-goal section to make the new placement visible; production keeps that section unchanged.

## Placement and navigation

Keep Practice, Chats and Goal. Place the entry immediately after the Goal word-total table, before the trend chart. Personal goals stay first; comparison is an optional next step. The entire compact card opens a pushed screen; Back returns to the same Goal screen. The card shows a seven-day all-language total, rank (or an em dash before speaking), and an explicit View leaderboard label.

Full screen: Speaking leaderboard; Last 7 days; a server-supplied inclusive date range and UTC. This is today's UTC calendar date and its six predecessors, not Monday-to-Sunday “This week” and not a sliding 168-hour interval. Do not attach a learning-language filter to this API.

## Visuals

- [Goal entry, light](goal-light.png) / [dark](goal-dark.png)
- [Leaderboard, light](leaderboard-light.png) / [dark](leaderboard-dark.png)
- [Empty and no speaking activity](empty.png) / [recoverable error](error.png)

The first three ranks have restrained gold, silver and bronze numerals, without a podium. Competition ranking is 1, 2, 2, 4: tied totals have equal rank and equal medal colour. The current user's lavender surface, purple border and “You” text distinguish it without relying on colour alone.

## Identity and language interactions

Every learner's name and profile photo are visible. There is no eye button, hide setting, confirmation dialog or row action in this version. The owner's normal list row carries “You”. Missing names use the localized “Learner” fallback and absent photos use the standard profile avatar. Previously stored visibility choices do not affect this release's ranking; the preference table remains intact for database compatibility. A future opt-out feature is deferred until requested.

Each row shows only the learner's current profile learning language, as secondary text: for example, Learning English(en-us 🇺🇸) or Learning Japanese 🇯🇵. There is no language breakdown, +N control or language-detail sheet. This follows the user's revised preference. Rows are informational and do not open a visibility action.

The total still combines speaking in every language. Changing the current learning language updates only the secondary label, never past contributions or rank. The subtitle says only Last 7 days, with the date range below. The API returns learningLanguage, not a per-language breakdown.

Country flags use the selected profile accent's real country flag. Multiple-accent languages retain their locale code, matching the Goal profile header. Never infer a US flag from generic English or substitute a globe for Latin American Spanish. Omit an unknown or unset learning-language label.

## Reading, updates and edge states

- Load the ranking in pages of 100. Scrolling near the end loads the next page; an explicit Load more button provides an alternative. Users below the first 100 appear at their normal position after loading later pages. The Goal card can still show the user's exact rank.
- There is no pinned, floating, duplicated or separate bottom own-position row. The normal list row carries “You” when it scrolls into view. Stable opaque daily row keys prevent duplicate users when pages overlap because of concurrent score updates. A manual refresh reconciles changed rankings.
- Pull to refresh. While the screen is active, check for new data every minute. Keep the displayed order fixed; show a polite Updated rankings are ready action only when ranking/identity/window data differs. Apply the next snapshot only on user refresh. Newly loaded pages append without rearranging visible rows. No repeated announcements for unchanged snapshots.
- Loading: static neutral skeleton rows and small progress indicator. Avoid pulsing motion. Empty board: friendly start-a-conversation copy. No personal speaking: unranked dash, zero, and a Practice/Chats instruction, not last place.
- Refresh failure: keep the last successful list and offer Retry. No stale cross-account state; clear immediately on account change.
- Long names wrap to two lines at standard size. At larger text sizes, remove the line limit and move the total below the identity. Preserve exact totals, never compact 12,450 to 12K.
- Touch targets are at least 44 points. Native controls expose labels and states. Live-region notices announce new results without moving focus. No rank-change confetti or shame-based messages.

## Implementation tokens

| Element | Specification |
|---|---|
| Page margin | 20 pt |
| Card radius | Entry 20 pt; ranking row 18 pt |
| Spacing | 4 / 6 / 8 / 10 / 12 / 16 / 20 / 24 pt |
| Row padding | 10 pt left, 14 pt top/right/bottom; language label below name |
| Avatar | 38 pt diameter; neutral silhouette when absent |
| Rank column | 34 pt, tabular numerals |
| Main title | 20 pt semibold/bold; dynamic text scaling |
| Names / main subtitle | 16 pt, 600 |
| Word total | 18 pt, 700, tabular numerals |
| Entry metrics | 26 pt, 700 |
| Secondary text | 12–14 pt; current learning language is secondary |
| Light | Background #F7F8FA, surface #FFFFFF, text #1E1E24, accent #6B4EE6 |
| Dark | Background #121212, surface #1E1E1E, text #F3F4F6, accent #8A72F6 |
| Current user | Primary at 9% fill and 40% border, full primary total |
| Medals, light | Gold #886514, silver #667085, bronze #91603E |
| Medals, dark | Gold #E4BF66, silver #BFC7D6, bronze #DCA078 |
| Refresh | 60-second foreground checks; explicit application of new order |

Components: SpeakingLeaderboardCard, SpeakingLeaderboardScreen, SpeakingLeaderboardView, SpeakingLeaderboardRow. Account-owned requests use existing refreshed authentication. Rendering and example snapshots are independently testable. Pixel comparisons use macOS system fonts and run on macOS only; behavior, scrolling and large-text layout assertions run on every platform, including Linux CI. All new strings are localized into the existing 17 UI languages.

## Data and migration decisions

New spoken activity also accumulates in per-device UTC date/language buckets. Existing personal statistics retain their local-day ledger. The backend accepts cumulative UTC snapshots with GREATEST upserts in one transaction; retries cannot add a snapshot twice. Once a device has uploaded its UTC window, ranking excludes its old local-day source to prevent double-counting. The ranking sums across devices and all languages, then uses SQL RANK before pagination. Stable per-day row keys are HMACs using the existing server signing secret; raw account IDs are not included as row fields. Profile visibility does not enter the aggregation filter.

Historical limitation: old versions saved dates without timestamps/time zones. Exact UTC conversion cannot be recovered. Their recorded calendar dates are preserved and a visible note explains this. New records use UTC. An upgraded device's imported historical window is marked as legacy until it ages out. Older unupgraded devices continue using recorded-date fallback so their contributions do not vanish. Do not describe this fallback as precisely reconstructed UTC history.

The already deployed migration added three tables (UTC device sources, UTC speaking counts and the now-unused profile visibility preference), with user-delete cascading. No new migration is needed to show all profiles. The legacy visibility PUT route returns 409 for hide requests, without writing data; the current app has no caller. Old APIs, local goals, practice-level scoring, CallKit and admin “This week” reports retain their contracts. No new secrets required. A server backup must precede deployment; rollback keeps the additive tables and user writes.

Metrics are word counts rather than proficiency scores. Counts use existing language-specific tokenisation, so comparisons across writing systems are approximate measures of activity. No financial rewards or competitive prizes are attached. Client-synced counts are not cheat-proof; a future rewarded competition would require server-verifiable activity events and abuse controls.

## Research used

- [Apple: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility): native accessibility, legible contrast and alternatives to colour-only meaning.
- [Apple: Dynamic Type](https://developer.apple.com/videos/play/wwdc2024/10074/): adapt layout for large text instead of shrinking it.
- [W3C: Focus not obscured](https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-enhanced): keep the ranking free of floating overlays that obscure list content.
- [W3C: Status messages](https://www.w3.org/WAI/WCAG21/Understanding/status-messages.html): announce refresh availability without stealing focus.
- [Leaderboard Effects on Player Performance](https://arxiv.org/abs/1707.03704): competition is not a universal motivation improvement; keep personal progress primary and avoid pressure-oriented presentation. This is a design inference, not a guarantee of increased engagement.

Recommended future UX validation: observe beginner and advanced learners finding their own row, understanding the date window, and understanding that the language label does not filter the word total. Physical-device usability and locked-screen call audio are not established by automated builds/tests.

## Delivery

Published backend 1.32.2 and website 0.17.1 as bantera-20261021-9, with live checks passed. Signed iOS 3.3.2 (425) installed on the requested iPhone and confirmed in its app inventory; not launched or physically tested. Names/photos are visible for every ranked learner, with no hiding controls.

The Play release build is 3.3.3 (426). Its only change after 3.3.2 is making Mac-font image comparisons platform-specific; product behavior is unchanged.
