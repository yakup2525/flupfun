import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'ad_pacing.dart';

class MonetizationService extends ChangeNotifier with WidgetsBindingObserver {
  static final instance = MonetizationService._();
  MonetizationService._();
  static const _productionUnit = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ID',
  );
  static const _audience = String.fromEnvironment('ADS_AUDIENCE');
  // Release builds are blocked by Gradle until an audited audience is supplied.
  static const _childDirected = _audience != 'general';
  final pacing = AdPacing(DateTime.now());
  InterstitialAd? _ad;
  DateTime? _loadedAt;
  Box<String>? _pacingStore;
  int _loadGeneration = 0;
  bool _privacyOpen = false;
  bool _opportunityBusy = false;
  bool _loading = false;
  bool _initialized = false;
  bool _started = false;
  bool _fullscreen = false;
  bool _foreground = true;
  bool _privacyRequired = false;
  bool get privacyRequired => _privacyRequired;
  bool get fullscreen => _fullscreen;

  Future<void> start() async {
    if (_started || defaultTargetPlatform != TargetPlatform.android) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    try {
      _pacingStore = await Hive.openBox<String>('ad-pacing');
      final saved = _pacingStore?.get('impressions');
      if (saved != null) {
        pacing.impressions.addAll(saved.split(',').map(DateTime.tryParse).whereType<DateTime>());
      }
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.g,
          ageRestrictedTreatment: _childDirected
              ? AgeRestrictedTreatment.child
              : AgeRestrictedTreatment.unspecified,
        ),
      );
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(tagForUnderAgeOfConsent: _childDirected),
        () => ConsentForm.loadAndShowConsentFormIfRequired((_) => _refresh()),
        (_) => _refresh(),
      );
    } catch (_) {
      /* Offline/plugin failure must never block play. */
    }
  }

  Future<void> _refresh() async {
    try {
      _privacyRequired =
          await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
      notifyListeners();
      if (!await ConsentInformation.instance.canRequestAds()) {
        _loadGeneration++;
        _loading = false;
        _ad?.dispose();
        _ad = null;
        return;
      }
      if (!_initialized) {
        _initialized = true;
        await MobileAds.instance.initialize();
      }
      _preload();
    } catch (_) {
      /* Gameplay remains available. */
    }
  }

  Future<bool> showPrivacyChoices() async {
    if (_fullscreen || !_privacyRequired) return false;
    _fullscreen = true;
    _privacyOpen = true;
    _loadGeneration++;
    _loading = false;
    _ad?.dispose();
    _ad = null;
    final done = Completer<bool>();
    try {
      ConsentForm.showPrivacyOptionsForm((error) {
        _fullscreen = false;
        _privacyOpen = false;
        unawaited(_refresh());
        if (!done.isCompleted) done.complete(error == null);
      });
    } catch (_) {
      _fullscreen = false;
      _privacyOpen = false;
      done.complete(false);
    }
    return done.future;
  }

  void completedRound() => pacing.completedRound();

  void _preload() {
    if (_loading || _ad != null || !_initialized || _fullscreen) return;
    if (kReleaseMode && _productionUnit.isEmpty) return;
    _loading = true;
    final generation = _loadGeneration;
    InterstitialAd.load(
      adUnitId: kReleaseMode
          ? _productionUnit
          : 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(nonPersonalizedAds: true),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (generation != _loadGeneration || _privacyOpen) { ad.dispose(); return; }
          _loading = false;
          _loadedAt = DateTime.now();
          _ad = ad;
        },
        onAdFailedToLoad: (_) {
          if (generation == _loadGeneration) _loading = false;
        },
      ),
    );
  }

  /// Called only from the game-over Play Again action, before restarting.
  Future<void> betweenRounds() async {
    if (_opportunityBusy || _fullscreen || !_foreground || !pacing.eligible(DateTime.now())) return;
    _opportunityBusy = true;
    try {
      if (!await ConsentInformation.instance.canRequestAds() || !_foreground) return;
      if (_loadedAt != null && DateTime.now().difference(_loadedAt!) >= const Duration(minutes: 55)) {
        _ad?.dispose();
        _ad = null;
      }
      final ad = _ad;
      if (ad == null) {
        _preload();
        return;
      }
      _ad = null;
      _fullscreen = true;
      final done = Completer<void>();
      var finished = false;
      void finish() {
        if (finished) return;
        finished = true;
        ad.dispose();
        _fullscreen = false;
        if (!done.isCompleted) done.complete();
        _preload();
      }

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (_) {
          pacing.record(DateTime.now());
          unawaited(_savePacing());
        },
        onAdDismissedFullScreenContent: (_) => finish(),
        onAdFailedToShowFullScreenContent: (_, _) => finish(),
      );
      try {
        await ad.show();
      } catch (_) {
        finish();
      }
      await done.future;
    } catch (_) {
      _fullscreen = false;
    } finally {
      _opportunityBusy = false;
    }
  }

  Future<void> _savePacing() async {
    try {
      await _pacingStore?.put('impressions', pacing.impressions.map((at) => at.toIso8601String()).join(','));
    } catch (_) { /* A storage failure must not hold the fullscreen lock. */ }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && _started && !_fullscreen) unawaited(_refresh());
    // Resuming is never an ad placement.
  }
}
