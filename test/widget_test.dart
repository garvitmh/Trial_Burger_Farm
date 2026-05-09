// ============================================================================
// FILE: test/widget_test.dart
// CHANGES:
//   - Fixed test to pump BurgerFarmApp wrapped in ProviderScope
//   - BurgerFarmApp is the actual app entry point in lib/main.dart
// ============================================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burger_farm_app/main.dart';

void main() {
  testWidgets('BurgerFarmApp smoke test', (WidgetTester tester) async {
    // Build the actual app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: BurgerFarmApp(),
      ),
    );

    // Verify the app renders without errors
    expect(find.text('Burger Farm'), findsOneWidget);
  });
}
