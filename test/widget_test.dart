import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:receipt_vault/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ReceiptVaultApp(),
      ),
    );

    // Verify that the app title is displayed.
    expect(find.text('ReceiptVault'), findsWidgets);

    // Verify that the tagline is displayed.
    expect(find.text('Smart Receipt Scanning for Lebanon'), findsOneWidget);

    // Verify the Get Started button is present.
    expect(find.text('Get Started'), findsOneWidget);
  });
}
