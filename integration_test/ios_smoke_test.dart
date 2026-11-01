import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flupfun/main.dart' as app;
import 'package:flupfun/ui/game/home_page.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('iOS launch, settings, gameplay and restart', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('FLUP FUN'), findsOneWidget);
    await binding.takeScreenshot('01-welcome');
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    await binding.takeScreenshot('03-settings');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(HomePage));
    await tester.pump(const Duration(milliseconds: 500));
    await binding.takeScreenshot('02-flight');
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('PLAY AGAIN'), findsOneWidget);
    await tester.tap(find.text('PLAY AGAIN'));
    await tester.pumpAndSettle();
    expect(find.text('FLUP FUN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
