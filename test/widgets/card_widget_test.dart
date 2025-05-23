import 'package:flutter_test/flutter_test.dart';
import 'package:persian_hokm/widgets/card_widget.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('CardWidget displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CardWidget(
            suit: 'spades',
            value: 'A',
          ),
        ),
      ),
    );

    // Verify that the widget displays the correct suit and value
    expect(find.byType(CardWidget), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('CardWidget handles different suits', (WidgetTester tester) async {
    // Test different suits
    final suits = ['spades', 'hearts', 'diamonds', 'clubs'];
    
    for (var suit in suits) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardWidget(
              suit: suit,
              value: 'K',
            ),
          ),
        ),
      );
      
      expect(find.byType(CardWidget), findsOneWidget);
      expect(find.text('K'), findsOneWidget);
    }
  });
}
