/// Only completed rounds can create an opportunity; time alone never shows ads.
class AdPacing {
  AdPacing(this.startedAt);
  final DateTime startedAt;
  int rounds = 0;
  int shownThisSession = 0;
  final List<DateTime> impressions = [];

  void completedRound() => rounds++;

  bool eligible(DateTime now) {
    impressions.removeWhere(
      (at) => now.difference(at) >= const Duration(hours: 1),
    );
    return now.difference(startedAt) >= const Duration(minutes: 5) &&
        rounds >= 10 &&
        shownThisSession < 2 &&
        impressions.length < 2 &&
        (impressions.isEmpty ||
            now.difference(impressions.last) >= const Duration(minutes: 30));
  }

  void record(DateTime now) {
    impressions.add(now);
    shownThisSession++;
    rounds = 0;
  }
}
