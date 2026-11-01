import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flupfun/services/ad_configuration.dart';

void main() {
  test('development units are platform-specific demo units', () {
    for (final p in [TargetPlatform.android, TargetPlatform.iOS]) {
      expect(
        interstitialUnitFor(p, release: false, androidProduction: 'unused'),
        startsWith('ca-app-pub-3940256099942544/'),
      );
    }
    expect(
      interstitialUnitFor(
        TargetPlatform.iOS,
        release: false,
        androidProduction: 'unused',
      ),
      endsWith('/4411468910'),
    );
  });
  test('iOS production never inherits Android build defines', () {
    expect(
      interstitialUnitFor(
        TargetPlatform.iOS,
        release: true,
        androidProduction: 'android-only',
      ),
      'ca-app-pub-9384489712257906/7747611505',
    );
    expect(
      interstitialUnitFor(
        TargetPlatform.android,
        release: true,
        androidProduction: '',
      ),
      isNull,
    );
    expect(
      interstitialUnitFor(
        TargetPlatform.android,
        release: true,
        androidProduction: 'android-only',
      ),
      'android-only',
    );
    expect(
      interstitialUnitFor(
        TargetPlatform.macOS,
        release: true,
        androidProduction: 'android-only',
      ),
      isNull,
    );
  });
}
