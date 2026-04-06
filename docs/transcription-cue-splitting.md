# Transcription Cue Splitting — Per-Sentence Accurate Timestamps

## Problem

When transcribing AI-generated audio in non-English languages (Chinese, Korean, French, German, Spanish, etc.), the practice player showed a single cue containing the **entire dialogue** as one long text block. English worked fine. The issue was first noticed with Chinese but affects all languages where the speech recogniser segments at sentence level rather than word level.

## Root Cause

`SpeechTranscriber` emits results at different granularities depending on language:

- **English**: one `result` per word or short phrase → already short → the original one-result-one-cue approach worked fine.
- **All other languages**: one `result` per full sentence, or even the entire utterance → one giant result → one giant cue.

The original code treated each `result` as one cue:

```swift
for try await result in transcriber.results {
    let cleaned = String(result.text.characters)  // entire sentence = one cue
    cues.append(TranscriptCuePayload(..., text: cleaned))
}
```

## Investigation

`SpeechTranscriber` was already initialised with `attributeOptions: [.audioTimeRange]`, meaning per-character timing should be attached to each attributed string run. The obstacle was not knowing the correct public Swift type name to access the attribute.

Added temporary debug logging to print every result and every run with all attributes:

```swift
for try await result in transcriber.results {
    print("[Bantera] result[\(i)] text='\(String(result.text.characters))' range=...")
    for (j, run) in result.text.runs.enumerated() {
        print("[Bantera]   run[\(j)] text='\(...)' attributes=\(run.attributes)")
    }
}
```

Log output (Chinese, truncated) confirmed:

```
[Bantera] result[0] text='你好 ，打扰一下 ，我想我好像走错路了。你好 ，请问你想去哪儿 ？...' range=0.0s-26.28s
[Bantera]   run[0] text='你' attributes={
    Speech.TimeRangeAttribute = CMTimeRange(start: 0s, duration: 0.42s)
}
[Bantera]   run[1] text='好' attributes={
    Speech.TimeRangeAttribute = CMTimeRange(start: 0.42s, duration: 0.18s)
}
[Bantera]   run[17] text='。' attributes={
    Speech.TimeRangeAttribute = CMTimeRange(start: 3.66s, duration: 0.24s)
}
[Bantera]   run[18] text='你' attributes={
    Speech.TimeRangeAttribute = CMTimeRange(start: 3.90s, duration: 0.42s)
}
```

Key findings:

1. Only **one `result`** for the entire transcript regardless of how many sentences.
2. Each `run` is **one character** with accurate per-character timing.
3. The attribute prints as `Speech.TimeRangeAttribute` in the log. The correct public Swift type — confirmed via [Apple docs](https://developer.apple.com/documentation/foundation/attributescopes/speechattributes) — is `AttributeScopes.SpeechAttributes.TimeRangeAttribute`.
4. This is **not a CJK-only issue** — it affects all languages where the recogniser groups speech into long results.

First approach after reading the log used `Mirror`-based reflection to find `CMTimeRange` inside `AttributeContainer` at runtime. This failed because `AttributeContainer` wraps values in internal box types that reflection cannot cast through. The Apple docs then confirmed the correct subscript key, making Mirror unnecessary.

## Solution

Replaced the one-result-one-cue approach with `cuesFromAttributedRuns`, which reads real per-character timestamps from each run and groups characters into cues at sentence-ending punctuation boundaries:

```swift
for run in text.runs {
    guard let timeRange = run[AttributeScopes.SpeechAttributes.TimeRangeAttribute.self] else { continue }
    // accumulate characters into buffer
    // flush into a new cue at 。！？.!? boundaries
    // startMs and endMs come from the actual character timestamps — no estimation
}
```

Sentence enders: `。！？.!?` — covers all scripts. Falls back to the original whole-result approach if no per-run timing is present, preserving English behaviour.

**Before:** 1 cue, entire dialogue, unusable for cue-by-cue practice.  
**After:** one cue per sentence for all languages, accurate start/end timestamps from the speech recogniser.

## Files Changed

| File | Change |
|---|---|
| `app/ios/Runner/AppDelegate.swift` | Added `cuesFromAttributedRuns`, updated transcription loop to use it; permanent `[Bantera]` debug logging added |

## Debug Logs

The `[Bantera]` print statements remain in `AppDelegate.swift`. Filter by `[Bantera]` in the Xcode console to inspect transcription results and per-character timing for any language.
