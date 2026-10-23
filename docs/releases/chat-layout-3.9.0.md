# Bantera AI chat layout 3.9.0 (437)

AI responses use the available conversation width without a background bubble,
outline or horizontal bubble padding. User messages retain their existing bubble.
Audio playback, translations, source/image/video cards and message actions remain
in the same message row.

Markdown supports headings, emphasis, lists, quotations, links and code blocks.
Tables have readable cell padding and headers; wide tables scroll horizontally,
with column widths accounting for larger accessibility text. Markdown images
continue to use the existing image-card flow, and links retain URL validation.

Transient chat context encourages useful Markdown in written replies and compact
tables for comparisons, without storing this instruction as a learner message.
Audio replies prioritize natural speech and numbered points; audio transcription
does not guarantee Markdown tables. Real-time phone-call context is unchanged.
No backend or website deployment is required.

Validation: 32 focused chat, Markdown, callback, CallKit and audio regression tests
passed, including full-width response layout and horizontally scrolling tables at
large text sizes. Changed-file static analysis passed. Physical-device testing is
left to the user; an installation does not verify locked-screen callback audio.

Unsigned iOS debug and signed release builds passed. Code signature verification
passed, and 3.9.0 (437) was installed on the requested iPhone without launching it.
