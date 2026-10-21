# Google Play 3.3.3 (426)

Submitted on 22 October 2026 (Pacific/Auckland) through the built-in browser.
Play Console confirmed **1 change sent for review** and **Changes in review**.
Google's automated quick checks were still running at confirmation. This is
submission evidence, not approval or public availability.

- Production rollout: 100%, all existing targeted countries.
- Managed publishing: off, so approval publishes automatically.
- Release notes: saved and confirmed for all 18 configured languages; see
  [localized notes](google-play-3.3.3-notes.txt).
- Signed AAB: version 3.3.3, version code 426, upload certificate CN=Bantera.
- SHA-256: `95665e2159beb64588abd59c4f4fd055d330719e6db245743132c685e15b4597`.
- Supported devices unchanged from production 3.1.0 (421).
- Focused layout/callback tests: 43 passed. Required iOS debug build and Android
  release bundle succeeded. The only change after 3.3.2 is Mac-specific design
  image comparison; layout/behavior tests still run on every platform.

Source commits pushed to main before submission: app b38c2bb, backend fc0e802,
website b70d5f5. Live server versions remain backend 1.32.2 and website 0.17.1.
The user's iPhone remains on the previously verified 3.3.2 (425) install.
No iOS App Store submission was made.
