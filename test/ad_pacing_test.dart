import 'package:flutter_test/flutter_test.dart';
import 'package:flupfun/services/ad_pacing.dart';

void main() {
  test(
    'grace, rounds, cooldown and session cap are independent requirements',
    () {
      final start = DateTime.utc(2026);
      final policy = AdPacing(start);
      for (var i = 0; i < 10; i++) {
        policy.completedRound();
      }
      expect(policy.eligible(start.add(const Duration(minutes: 4))), isFalse);
      final first = start.add(const Duration(minutes: 5));
      expect(policy.eligible(first), isTrue);
      policy.record(first);
      expect(policy.eligible(first.add(const Duration(minutes: 10))), isFalse);
      for (var i = 0; i < 10; i++) {
        policy.completedRound();
      }
      expect(policy.eligible(first.add(const Duration(minutes: 29))), isFalse);
      final second = first.add(const Duration(minutes: 30));
      expect(policy.eligible(second), isTrue);
      policy.record(second);
      for (var i = 0; i < 10; i++) {
        policy.completedRound();
      }
      expect(policy.eligible(second.add(const Duration(hours: 2))), isFalse);
    },
  );
}
