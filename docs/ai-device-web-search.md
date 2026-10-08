# Bantera AI: device web search

`search_web` is a custom Gemini Live function, available in both real-time audio
calls and streamed voice-message replies. The **app** makes the search HTTP
request. The backend declares the function and relays its request/result; it does
not contact the search engine or fetch result pages.

## Flow and interface

1. The app advertises `metadata.deviceWebSearch: true` when opening either AI
   WebSocket. Older clients default to false. Upload-only HTTP replies disable
   the capability because they have no device tool response channel.
2. Gemini requests `search_web` with a short `query`. The phone contacts
   `https://html.duckduckgo.com/html/` directly, without Bantera credentials,
   cookies, a shared search API key or a server search proxy.
3. The app parses up to five result titles, HTTPS links and short excerpts. It
   returns these to Gemini through the authenticated existing socket. This is
   online processing: DuckDuckGo receives the query and Gemini receives excerpts.
4. The bubble shows searching/unavailable status and tappable source cards.
   Tapping a source opens the system browser view inside Bantera, with browser
   controls to return to the chat (Safari view on iOS, Custom Tabs on Android
   with an in-app WebView fallback).
   Source cards persist only in account-scoped device history. Clearing chat
   history removes them. Usage help explains this data flow.

DuckDuckGo documents its HTML search interface, but this is **not a guaranteed
search API**. Page changes, provider challenges and network failures return an
unavailable result. The app never solves or bypasses challenges. It does not
claim snippets are full articles or verified facts. Gemini is instructed to
ignore instructions inside results and retain the learner's language/accent/level.

## Bounds and lifecycle

- Query: 240 characters; four uncached searches per minute; eight cache entries,
  each valid for five minutes, in memory only.
- Network: eight-second total timeout; 768 KB maximum HTML body; no redirects.
- Results: five sources, 160-character titles, 500-character excerpts; only HTTPS
  links without user info, IP literals or local/internal hostnames. Result pages
  open only when the user taps, and are never automatically fetched.
- Voice relay: four tool requests per operation, 12-second device deadline,
  bounded correlated responses. Call interruption cancels pending provider tool
  responses; late replies do not restart an interrupted turn.
- Search runs outside audio playback queues. Ending a call, changing account or
  disposing the controller cancels in-flight searches and guards late updates.
- Going to the background does not cancel a **sent** voice reply. iOS already has
  the audio background mode and a playback audio session. Native playback failure
  no longer aborts receiving/saving audio and transcription. Partial replies
  remain visible; playback-only problems do not mark the user's message failed.
  OS termination and network loss can still prevent receipt of missing data.

## Release notes

App 2.4.0 (327) and backend 1.4.0 are required for the new search capability.
Existing published clients retain their original protocol. No migration,
provider secret or new environment variable is needed. Deploying the backend
and installing the app are separate authorized release steps.

Sources: [DuckDuckGo HTML search](https://duckduckgo.com/duckduckgo-help-pages/features/non-javascript),
[Gemini Live tools](https://ai.google.dev/gemini-api/docs/live-api/tools).
