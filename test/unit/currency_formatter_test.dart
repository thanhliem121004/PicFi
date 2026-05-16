import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:picfi/core/utils/currency_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('vi', null);
  });

  group('CurrencyFormatter.format', () {
    test('format(1000) returns 1.000 đ', () {
      expect(CurrencyFormatter.format(1000), '1.000 đ');
    });

    test('format(50000) returns 50.000 đ', () {
      expect(CurrencyFormatter.format(50000), '50.000 đ');
    });

    test('format(0) returns 0 đ', () {
      expect(CurrencyFormatter.format(0), '0 đ');
    });

    test('format(1234567) returns 1.234.567 đ', () {
      expect(CurrencyFormatter.format(1234567), '1.234.567 đ');
    });
  });

  group('CurrencyFormatter.formatShort', () {
    test('formatShort(1500000) returns 1.5M', () {
      expect(CurrencyFormatter.formatShort(1500000), '1.5M đ');
    });

    test('formatShort(2000000) returns 2.0M', () {
      expect(CurrencyFormatter.formatShort(2000000), '2.0M đ');
    });

    test('formatShort(5000) returns 5K đ', () {
      expect(CurrencyFormatter.formatShort(5000), '5K đ');
    });

    test('formatShort(999) returns 999 đ', () {
      expect(CurrencyFormatter.formatShort(999), '999 đ');
    });
  });

  group('CurrencyFormatter.formatCompact', () {
    test('formatCompact(50000) returns compact format', () {
      final result = CurrencyFormatter.formatCompact(50000);
      expect(result, '50.000đ');
    });

    test('formatCompact(1000) returns 1.000đ', () {
      expect(CurrencyFormatter.formatCompact(1000), '1.000đ');
    });
  });

  group('CurrencyFormatter.parse', () {
    test('parse("50.000") returns 50000', () {
      expect(CurrencyFormatter.parse('50.000'), 50000);
    });

    test('parse("1.234.567") returns 1234567', () {
      expect(CurrencyFormatter.parse('1.234.567'), 1234567);
    });

    test('parse("1.234.567 đ") returns 1234567', () {
      expect(CurrencyFormatter.parse('1.234.567 đ'), 1234567);
    });

    test('parse("abc") returns null', () {
      expect(CurrencyFormatter.parse('abc'), null);
    });

    test('parse("") returns null', () {
      expect(CurrencyFormatter.parse(''), null);
    });
  });
}
