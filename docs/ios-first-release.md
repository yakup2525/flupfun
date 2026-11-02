# Flup Fun first iOS release

## Verified configuration

- Bundle ID: `com.kurtizi.flupfun`; Apple Team: `46T7M87N6F`.
- App Store Connect app: `6829191394`, SKU `flupfun-ios`.
- Marketing version/build: `1.1.9 (10)`. This is the first iOS release; the existing Android version is retained.
- Native AdMob app ID: `ca-app-pub-9384489712257906~4223299469`.
- iOS interstitial: `ca-app-pub-9384489712257906/7747611505`; debug uses Google's iOS demo unit. Both production registrations were checked in AdMob.
- Production command: `scripts/build_ios_release.sh` with the checked-in iOS audience configuration. Child age treatment, G-rated ads, non-personalized requests, and publisher first-party ID disabled. No ATT prompt or IAP.
- UMP update and required form precede the canRequestAds gate. Privacy Choices appears only when UMP requires it. Failure does not block gameplay.

## Store artwork

`test_driver/ios_smoke.dart` writes actual simulator screenshots to the directory selected by `FLUP_SCREENSHOTS`. `integration_test/ios_smoke_test.dart` exercises welcome, settings, flight with an obstacle, game over, and restart.

`scripts/generate_store_screenshots.cjs` requires Node and Sharp. It embeds the intact captures from `deploy/ios-captures` and `deploy/ios-captures-ipad` in branded layouts. Outputs under `deploy/ios-store` are opaque PNGs: iPhone 1206 × 2622 and iPad 2064 × 2752. Two images per device were uploaded and verified in App Store Connect. Gameplay is not generated or retouched.

The mint angular character, navy background, rounded mint obstacles, icon, and original sound assets establish a separate presentation. The tap-to-fly genre remains recognizable; App Review acceptance is not guaranteed.

## Validation and current limits (November 2, 2026)

- Flutter analysis clean; ten unit/widget tests passed.
- iPhone and iPad simulator smoke tests passed, including obstacle flight, settings, game over, and restart. The final iPad run also verified the game's pause/resume lifecycle handler without suspending the Flutter test binding itself; this is a callback test, not an OS-driven background/foreground test.
- Exported production IPA passed deep/strict codesign verification and uses Apple Distribution for the expected team.
- Apple rejected the first upload because portrait-only iPad orientations advertised multitasking. `UIRequiresFullScreen` now declares the game's portrait compatibility mode. The corrected archive passed signature validation, uploaded successfully, processed as Ready to Submit, and build 10 was attached to version 1.1.9.
- Corrected IPA: `build/ios/ipa/flupfun.ipa`, SHA-256 `e96b98ba8d66885646f29141fd31bb93a0e9b9a30faf67599125910491c8ac8b`.
- Apple emitted nonfatal missing-dSYM warnings for GoogleMobileAds and UMP; this limits symbolication of SDK crashes.
- Store metadata, privacy-policy URL, age rating 4+, review contact/notes, content rights, and actual screenshot sets saved. App Privacy was published after explicit user approval. Version 1.1.9 (10) was submitted to App Review and verified as **Waiting for Review**, with **1 Item Submitted** (submission `852a8372-c936-47cd-bd3c-dd44e237b359`).
- The opt-in iOS UMP/demo ad loading integration test passed: canRequestAds returned true, Google's demo interstitial loaded, and gameplay remained available after disposal. The optional native dismissal test timed out because the computer tool cannot access Simulator; this is not a passed presentation/dismissal test. Sound audibility and a required Privacy Choices form have not been verified.
- `integration_test/ios_ads_test.dart` is opt-in with `FLUP_AD_TEST=true`. It checks UMP permission and loads/disposes Google's demo interstitial. Also set `FLUP_INTERACTIVE_AD_TEST=true` for a supervised show/dismiss test; close the native test ad within two minutes. Neither flag changes production app behavior.
- Published App Privacy covers coarse location, device ID, product interaction, advertising, crash, performance, and other diagnostic data from Google Mobile Ads. Purposes are third-party advertising/analytics (crash: analytics only), with no developer marketing. Device-linked categories are conservatively disclosed as linked; crash/other diagnostics are unlinked. Child age treatment, no IDFA permission, and publisher first-party ID disabled underpin the no-tracking response.
- User requires exclusion of regions that require publication of a personal address. After explicit confirmation, EU27 were excluded and availability in the remaining 148 regions was saved and verified. Automatic inclusion of future regions was disabled.
- User explicitly approved free pricing, pushing local commits to `origin/main`, and deploying the updated iOS privacy policy. Free pricing was saved. The policy was deployed through Cloudflare and the live page was verified to describe Android and iOS. Website check/build/validate passed; existing unrelated Ghost Runner link audit issues remain.

Upload, processing, and review submission are complete. Publication awaits Apple's approval; automatic release after approval is selected. EU27 remain excluded from availability.
