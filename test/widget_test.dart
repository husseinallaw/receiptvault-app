import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Simple test to verify basic widget rendering works
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('ReceiptVault'),
          ),
        ),
      ),
    );

    // Verify that the text is rendered
    expect(find.text('ReceiptVault'), findsOneWidget);
  });
}
