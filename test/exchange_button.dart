import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/main.dart';
import 'package:new_app/pages/exchange/escrow_process.dart';

void main() {
  testWidgets('Exchange button press without image selected shows error dialog', (WidgetTester tester) async {
    // Build the EscrowWidget
    await tester.pumpWidget(const MaterialApp(
      home: EscrowWidget(
        recipientEmail: 'test@example.com',
        loggedInUserEmail: 'user@example.com',
        productId: 'testProductId',
      ),
    ));

    // Find the Exchange button
    final exchangeButton = find.text('Exchange');

    // Tap on the Exchange button
    await tester.tap(exchangeButton);
    await tester.pump();

    // Verify that an error dialog is shown
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('No image selected.'), findsOneWidget);
  });
}
