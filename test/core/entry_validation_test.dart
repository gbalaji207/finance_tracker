import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/utils/entry_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseAmount', () {
    test('parses plain and formatted numbers', () {
      expect(parseAmount('32000'), 32000);
      expect(parseAmount('32,000.50'), 32000.5);
      expect(parseAmount('₹ 1,200'), 1200);
      expect(parseAmount(' 45 '), 45);
    });

    test('returns null for empty or invalid text', () {
      expect(parseAmount(''), isNull);
      expect(parseAmount('abc'), isNull);
    });

    test('a negative number parses but fails validation', () {
      expect(parseAmount('-5'), -5);
      expect(
        validateEntry(
          amountText: '-5',
          sourceId: 's',
          type: TxType.expense,
          categoryId: 'c',
        ),
        'Enter an amount above zero.',
      );
    });
  });

  group('validateEntry', () {
    test('checks the source first, then the category, then the amount', () {
      expect(
        validateEntry(
          amountText: '',
          sourceId: '',
          type: TxType.expense,
          categoryId: null,
        ),
        'Choose a source.',
      );
      expect(
        validateEntry(
          amountText: '',
          sourceId: 's',
          type: TxType.expense,
          categoryId: null,
        ),
        'Choose a category.',
      );
      expect(
        validateEntry(
          amountText: '',
          sourceId: 's',
          type: TxType.expense,
          categoryId: 'c',
        ),
        'Enter an amount above zero.',
      );
    });

    test('accepts a valid expense and a valid income without a category', () {
      expect(
        validateEntry(
          amountText: '500',
          sourceId: 's',
          type: TxType.expense,
          categoryId: 'c',
        ),
        isNull,
      );
      expect(
        validateEntry(
          amountText: '500',
          sourceId: 's',
          type: TxType.income,
          categoryId: null,
        ),
        isNull,
      );
    });
  });
}
