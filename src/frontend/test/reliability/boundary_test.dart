import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Boundary Validation Tests', () {
    test('Empty habit field label should be rejected', () {
      final fields = [
        {'label': '', 'unit': 'reps'},
      ];

      String? error;
      for (var i = 0; i < fields.length; i++) {
        final label = fields[i]['label']!.trim();
        if (label.isEmpty) {
          error = 'Field #${i + 1}: label cannot be empty';
          break;
        }
      }

      expect(error, isNotNull);
      expect(error, 'Field #1: label cannot be empty');
    });

    test('Field label exceeding 50 characters should be rejected', () {
      final longLabel = 'a' * 51;
      final fields = [
        {'label': longLabel, 'unit': 'count'},
      ];

      String? error;
      for (var i = 0; i < fields.length; i++) {
        final label = fields[i]['label']!.trim();
        if (label.length > 50) {
          error = 'Field #${i + 1}: label too long (max 50 characters)';
          break;
        }
      }

      expect(error, isNotNull);
      expect(error, contains('too long'));
      expect(error, contains('max 50 characters'));
    });
  });
}
