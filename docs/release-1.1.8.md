# Flup Fun 1.1.8 (9) release preparation

Previous production: 1.1.7 (8), confirmed in Play Console. Package: `com.kurtizi.flupfun`.

## Build

Flutter 3.44.9 / Dart 3.12.2, Android min 24 / target and compile 36, existing release keystore. Run `scripts/build_android_release.sh`. It uses public, non-secret production IDs in `config/ads.production.json`. Gradle rejects missing/demo release IDs and an audience other than `children`. Debug/profile manifests and Dart code always use Google's official test IDs, even when production defines are supplied. No signing material belongs in Git.

CI is manual and produces an artifact. It no longer bumps versions, pushes commits, or automatically publishes production releases.

## Ads and privacy

Google Mobile Ads Flutter 9.2.0 wraps Android Google Mobile Ads 25.5.0 and UMP 4.0.0. There is no mediation, rewarded ad, banner, Firebase, standalone analytics or crash SDK. Hive stores local best scores, ad pacing timestamps, and cached update policy. No accounts, gameplay backend, score uploads, purchases or leaderboard.

Play declares all age groups, including children. Every request uses `AgeRestrictedTreatment.child`, G maximum content rating and nonpersonalized ads. UMP receives under-age-of-consent treatment for everyone. No custom age gate. AD_ID and AdServices advertising ID, attribution and topics permissions are removed. UMP may therefore suppress consent solicitations in this child-treated flow; EEA adult consent/decline forms are not forced for QA or in release. Settings shows the official Privacy Choices entry only when UMP requires it.

Only the Game Over → Play Again action can present an interstitial. Minimum five-minute startup grace, ten completed rounds since the last shown ad, 30-minute cooldown, maximum two per rolling hour and two per app process/session. Hourly impression timestamps survive restarts. AdMob's existing Round Break unit also has a 2/60-minute/user cap. No launch or resume placement. A fullscreen lock, consent recheck and duplicate restart guard protect navigation. Network, consent and ad failures leave gameplay available.

Policy: https://wolftrailstudio.com/privacy/flup-fun/
Support: support@wolftrailstudio.com / privacy@wolftrailstudio.com

## Mandatory update operations

1.1.8 introduces the mechanism. It cannot force users of 1.1.7 or earlier. Future releases can require an update for users who installed 1.1.8 or later by changing `https://wolftrailstudio.com/updates/flup-fun.json`:

```json
{"minimumSupportedVersion":"1.1.8"}
```

Use a published and available version before increasing the minimum. Compare uses numeric major.minor.patch, never lexicographic ordering. The Play link is fixed to this package and cannot be replaced by remote policy. A known minimum is cached and remains enforced offline; a first offline start without a known policy permits gameplay. Invalid/failed remote requests do not crash or erase the last known valid policy. Back cannot dismiss a mandatory gate. Returning from the store rechecks the policy; a failed store launch offers retry and cannot bypass the gate. Raising the minimum cannot retroactively reach old builds without this code.

## Final QA

- `flutter analyze`: no issues.
- `flutter test`: seven tests pass, covering pacing, cooldown/session cap, minimum-version below/equal/above, malformed versions, offline first launch, cached offline enforcement, corrupt cache recovery, package store URL.
- Android emulator: official test-device ad requests, child flow without consent solicitation, Settings navigation, round completion, background/resume. After the real grace period and ten rounds, the official Google interstitial test ad displayed at Play Again; dismissal returned to tap-to-play, cleared the fullscreen lock, reset pacing, and started preload. No timing or version overrides were added. External policy/support destination handling and mandatory-screen/store-failure UI were not exercised end to end. Full EEA adult accept/decline/manage paths are inapplicable to the all-child-treated release; no forced geography or test-device overrides in source.
- Final signed AAB: `build/app/outputs/bundle/release/app-release.aab`.
- Artifact checks: package/version correct, production App ID in manifest, production unit in all three libapp.so ABIs, no Google demo publisher in manifest/libapp.so, no advertising ID/AdServices permissions; `jarsigner -verify` reports jar verified. The AAB certificate matches the configured existing release keystore (SHA-256 CF:F0:1F:A0:09:98:6C:99:2C:27:66:AA:21:0F:CE:2B:1B:CB:DA:BD:96:1F:EA:20:D5:E8:42:7D:81:F7:08:08); it was not independently compared with Play Console. Self-signed Android upload certificate is expected.

## Publication state (October 28, 2026)

Website commit `5afc4ef` was pushed normally to origin/main and deployed through the existing Cloudflare Workers workflow (deployment `dce3ac44-d959-4587-8d1c-77fc119ea454`). Production home and Flup Fun policy return HTTP 200; app-ads.txt returns 200 text/plain with the existing publisher line. The minimum-version endpoint returns 1.1.8. No unrelated product pages were changed.

Play public support and website metadata were published. Ads and policy declarations are saved for review. Data Safety was reviewed against Google's Mobile Ads 25.5.0 disclosure: approximate location, app interactions, diagnostics, device/other IDs; collected/shared, required, non-ephemeral; advertising, analytics and fraud/security purposes. Advertising ID remains No because the final manifest removes AD_ID/AdServices permissions and the child treatment suppresses advertising ID collection.

Google Play accepted the signed AAB as version 9 (1.1.8). The owner explicitly confirmed the children's legal acknowledgment at action time on October 28. The all-age audience and certified child-appropriate advertising declarations were completed. The production release and four declaration changes were submitted; Play shows them under changes in review, with automatic prechecks still running before review starts. Managed Publishing remains enabled. No final publication to users was performed.

AdMob remains linked to Play with the existing Round Break interstitial and 2/60 cap. European and US messages are published. App readiness/app-ads verification remains external/pending; no repeated rescan was requested.

AdMob's Flup Fun high-engagement ads setting was disabled and verified off to avoid extended viewing/closing steps. The optional console maximum-rating override could not be changed because native coordinate control failed on its inaccessible slider; the unsaved change was canceled. The shipping app explicitly sets G for every request, which overrides the console rating per https://support.google.com/admob/answer/7562142. Child treatment and nonpersonalized requests were rechecked; no source or bundle change was needed. AdMob 25.5.0 is within the Families self-certified versions (19.0.0 or later) listed at https://support.google.com/googleplay/android-developer/answer/12955712.
