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

## Publication blockers

Website privacy/update assets are committed in a separate clone; remote push was blocked by automatic approval review. Until deployment is approved, the new first-party policy and update JSON are not live. Existing website check/build/lint/validate pass; supplemental audit reports only pre-existing Ghost Runner external-link attributes, left untouched.

Keep Play Managed Publishing enabled. Do not make a reviewed production release live without owner approval.
