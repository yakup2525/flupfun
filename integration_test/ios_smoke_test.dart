import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flupfun/main.dart' as app;
import 'package:flupfun/ui/game/home_page.dart';
import 'package:flupfun/core/widgets/bird.dart';
import 'package:flupfun/core/widgets/barrier.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('iOS launch, settings, gameplay and restart', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('T A P  T O  P L A Y'), findsOneWidget);
    await binding.takeScreenshot('01-welcome');
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    await binding.takeScreenshot('03-settings');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(HomePage));
    for (var frame = 0; frame < 600; frame++) {
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.text('PLAY AGAIN'), findsNothing);
      final bird = tester.widget<MyBird>(find.byType(MyBird));
      if (bird.birdY > 0.2) await tester.tap(find.byType(HomePage));
      final barrier = tester
          .widgetList<MyBarrier>(find.byType(MyBarrier))
          .first;
      if (barrier.barrierX < 0.9) break;
    }
    expect(
      tester.widgetList<MyBarrier>(find.byType(MyBarrier)).first.barrierX,
      lessThan(0.9),
    );
    await binding.takeScreenshot('02-flight');
    final lifecycle =
        tester.state(find.byType(HomePage)) as WidgetsBindingObserver;
    lifecycle.didChangeAppLifecycleState(AppLifecycleState.paused);
    // Flush any frame already scheduled before the lifecycle transition.
    await tester.pump();
    final beforePause = tester.widget<MyBird>(find.byType(MyBird)).birdY;
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.widget<MyBird>(find.byType(MyBird)).birdY, beforePause);
    lifecycle.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('PLAY AGAIN'), findsOneWidget);
    await tester.tap(find.text('PLAY AGAIN'));
    await tester.pumpAndSettle();
    expect(find.text('T A P  T O  P L A Y'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
