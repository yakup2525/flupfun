# Flup Fun first iOS release

## Current candidate

The user authorized publishing the corrected design; the corrected submission was sent on November 3, 2026. Version **1.1.9 (11)** preserves the existing Android game's blue bird, light blue sky, green obstacles, brown scoreboard, original start screen, icon, and audio. Build 10's redesign was withdrawn and must not be resubmitted.

Play Console was checked directly: Android production is 1.1.9 (10), package `com.kurtizi.flupfun`, at 100% rollout. Original logo and bird PNGs in commit `2e6001f` match its release AAB exactly. The final iOS build 11 archive's six logo/sprite/audio files also match that Android baseline byte-for-byte.

## Configuration

- Bundle ID: `com.kurtizi.flupfun`; Apple Team: `46T7M87N6F`.
- App Store Connect app: `6829191394`, SKU `flupfun-ios`.
- iOS marketing version/build: `1.1.9 (11)`, selected through the build script's overrides. Android's pubspec version is unchanged.
- Native AdMob app ID: `ca-app-pub-9384489712257906~4223299469`.
- iOS interstitial: `ca-app-pub-9384489712257906/7747611505`; debug uses Google's iOS demo unit. Registrations were verified in AdMob.
- Child age treatment, G-rated ads, non-personalized requests, publisher first-party ID disabled. No ATT request or in-app purchases.
- UMP update and required form precede canRequestAds. Privacy Choices appears only when UMP requires it; failures never block gameplay.
- iOS-only safe-area adaptation and portrait full-screen declaration retained. Android avoids the iOS safe-area inset change.
- EU27 excluded; 148 remaining regions enabled by explicit user confirmation. Automatic availability in future regions disabled. Price is free; release is automatic after Apple's approval.

## Artwork

Canonical Android art must remain unchanged. `scripts/generate_release_art.swift` only resizes its existing logo into opaque iOS icons. It no longer generates replacement characters or source artwork.

`test_driver/ios_smoke.dart` captures actual simulator screens to `FLUP_SCREENSHOTS`. Restored captures are in `deploy/ios-captures-restored` and `deploy/ios-captures-restored-ipad`. `scripts/generate_store_screenshots.cjs` requires Node and Sharp and embeds those intact screenshots into layouts using the original palette. Outputs are in `deploy/ios-store-restored`: iPhone 1206 × 2622, iPad 2064 × 2752, two opaque PNGs per device. Gameplay is not generated or retouched.

## Verification

- Flutter analysis clean; ten unit/widget tests passed after restoration.
- Restored iPhone/iPad smoke tests passed startup, settings, obstacle flight, game over, restart, and the game's pause/resume handler. The lifecycle check invokes the game's callback; it is not an OS-driven background/foreground test.
- Opt-in UMP/demo interstitial loading test passed. Run with `FLUP_AD_TEST=true`; `FLUP_INTERACTIVE_AD_TEST=true` additionally requires manually closing the native demo ad within two minutes. Native dismissal, sound audibility, and a required Privacy Choices form have not been verified in this tool session.
- Build 11 archive and exported IPA passed deep/strict signature verification and identity/version checks. The iOS logo was visually checked against Android's original.
- Command: `IOS_BUILD_NAME=1.1.9 IOS_BUILD_NUMBER=11 scripts/build_ios_release.sh --export-options-plist=/private/tmp/flupfun-restored-export.plist`.
- IPA: `build/ios/ipa/flupfun.ipa`, SHA-256 `0c5a2af01271cfc115403ab5305a86cee872570062e27545ff60d7d43e27fca4`.
- Apple upload and processing succeeded. Build 11 replaced build 10 in the saved version. Corrected iPhone/iPad screenshots are attached; their original blue-bird gameplay previews were verified in App Store Connect.
- Submitted on November 3, 2026; verified **Waiting for Review** and **1 Item Submitted**. Submission ID: `b791b653-7356-44ee-aa15-6dbd83de7be0`. Automatic release after approval is selected; the app is not live yet.
- Nonfatal upload warnings: missing GoogleMobileAds/UMP dSYMs limit SDK crash symbolication. Flutter flags unused legacy launch-image assets; the actual launch storyboard displays a solid background and does not reference the default image.

## Store declarations

Metadata, age rating 4+, content rights, review contact/notes, and privacy-policy URL were saved. The live policy at `https://wolftrailstudio.com/privacy/flup-fun/` describes Android and iOS. App Privacy was published after explicit user approval and includes Google Mobile Ads coarse location, device ID, product interactions, advertising, crash, performance, and other diagnostics. Purposes are third-party advertising/analytics (crash: analytics only), with no developer marketing. Device-linked categories are conservatively disclosed as linked; crash/other diagnostics are unlinked. Child age treatment, no IDFA permission, and disabled publisher first-party ID underpin the no-tracking response. Visual restoration does not change SDK collection behavior.

The original submission `852a8372-c936-47cd-bd3c-dd44e237b359` was cancelled at the user's request and verified as Removed / Developer Rejected. The corrected submission uses build 11 and the restored screenshots; the withdrawn build and navy/mint screenshots are not included.
