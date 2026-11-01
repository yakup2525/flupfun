import 'package:flutter/foundation.dart';

/// Platform registrations are distinct; never send an Android unit to iOS.
String? interstitialUnitFor(
  TargetPlatform platform, {
  required bool release,
  required String androidProduction,
}) {
  return switch (platform) {
    TargetPlatform.android =>
      release
          ? (androidProduction.isEmpty ? null : androidProduction)
          : 'ca-app-pub-3940256099942544/1033173712',
    TargetPlatform.iOS =>
      release
          ? 'ca-app-pub-9384489712257906/7747611505'
          : 'ca-app-pub-3940256099942544/4411468910',
    _ => null,
  };
}
