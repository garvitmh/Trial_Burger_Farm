// Basic widget test for Burger Farm App.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Verify that the app can display a simple MaterialApp
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Burger Farm')),
        ),
      ),
    );

    expect(find.text('Burger Farm'), findsOneWidget);
  });
}
