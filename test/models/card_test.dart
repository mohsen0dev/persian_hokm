import 'package:flutter_test/flutter_test.dart';
import 'package:persian_hokm/models/card.dart';

void main() {
  group('Card model tests', () {
    test('Creates card with valid values', () {
      final card = Card(suit: 'spades', value: 'A');
      expect(card.suit, 'spades');
      expect(card.value, 'A');
    });

    test('Throws error with invalid suit', () {
      expect(() => Card(suit: 'invalid', value: 'A'), 
          throwsA(isA<ArgumentError>()));
    });

    test('Throws error with invalid value', () {
      expect(() => Card(suit: 'spades', value: 'invalid'), 
          throwsA(isA<ArgumentError>()));
    });

    test('Correctly converts to string', () {
      final card = Card(suit: 'hearts', value: 'K');
      expect(card.toString(), 'K of hearts');
    });
  });
}
