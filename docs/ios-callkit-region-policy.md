# iOS CallKit region policy

CallKit and PushKit VoIP registration are disabled when either of these reports
mainland China:

- The App Store storefront (`Storefront.current.countryCode`: `CHN`).
- The iPhone's Region setting (`Locale.current.region.identifier`: `CN`).

The native bridge starts disabled and checks before creating `CXProvider` or
`CXCallController`, or registering for VoIP pushes. Hong Kong, Macao and Taiwan
are separate regions. The UI language is not used to decide availability.
If StoreKit has no storefront, a known device Region is used. If both signals
are missing, system calling stays disabled. This is a storefront/device-region
policy, not a GPS or IP geofence.

The policy is checked on startup, when the app becomes active, when the device
locale changes, and when StoreKit reports a storefront update. Entering a
restricted region ends active system calls, invalidates providers and removes
the PushKit desired push type. Known previous VoIP tokens are queued locally
and removed through the existing authenticated backend endpoint; failed removal
is retried on a later registration attempt. An old build may not have saved a
token locally, so backend cleanup is best-effort for those tokens; PushKit
registration is still disabled on the device.

Human calls continue through the existing in-app interface and regular APNs
notifications. System AI callbacks are unavailable while restricted; new
scheduling requests receive no VoIP token. AI chat and in-app AI calls remain
available. There are no backend schema or endpoint changes.

## Verification

Simulator native tests cover mainland storefront/device combinations, absent
region information, other regions, provider/VoIP registration lifecycle, and
persisting token cleanup. Dart tests cover regional availability, suppressed
native reporting with the in-app fallback, and pending token cleanup methods.

For App Review, upload a new build containing this change and explain both
signals and the disabled CallKit/PushKit paths in Review Notes. Supply the
separately requested physical-device VoIP demonstration and reproduction steps.
Installing this build on a device does not update the App Store submission.
