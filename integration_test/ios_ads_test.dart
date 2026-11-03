import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flupfun/main.dart' as app;
import 'package:flupfun/services/ad_configuration.dart';
import 'package:flutter/foundation.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'iOS consent gate and demo interstitial',
    (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.runAsync(() async {
        var allowed = false;
        for (var attempt = 0; attempt < 30; attempt++) {
          allowed = await ConsentInformation.instance.canRequestAds();
          if (allowed) break;
          await Future<void>.delayed(const Duration(seconds: 1));
        }
        expect(allowed, isTrue, reason: 'UMP did not allow an ad request');
        await MobileAds.instance.initialize();
        final loaded = Completer<InterstitialAd>();
        await InterstitialAd.load(
          adUnitId: interstitialUnitFor(
            TargetPlatform.iOS,
            release: false,
            androidProduction: '',
          )!,
          request: const AdRequest(nonPersonalizedAds: true),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: loaded.complete,
            onAdFailedToLoad: loaded.completeError,
          ),
        );
        final ad = await loaded.future.timeout(const Duration(seconds: 45));
        if (!const bool.fromEnvironment('FLUP_INTERACTIVE_AD_TEST')) {
          ad.dispose();
          return;
        }
        final dismissed = Completer<void>();
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (_) =>
              debugPrint('DEMO_INTERSTITIAL_SHOWN'),
          onAdDismissedFullScreenContent: (_) => dismissed.complete(),
          onAdFailedToShowFullScreenContent: (_, error) =>
              dismissed.completeError(error),
        );
        debugPrint('DEMO_INTERSTITIAL_LOADED: close the simulator test ad');
        await ad.show();
        try {
          await dismissed.future.timeout(const Duration(minutes: 2));
        } finally {
          ad.dispose();
        }
      });
      await tester.pumpAndSettle();
      expect(find.text('T A P  T O  P L A Y'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    skip: !const bool.fromEnvironment('FLUP_AD_TEST'),
  );
}
