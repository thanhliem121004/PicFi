import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:picfi/core/utils/date_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('vi', null);
  });

  group('DateFormatter.formatRelative', () {
    test('returns "Hôm nay" for today', () {
      final today = DateTime.now();
      final result = DateFormatter.formatRelative(today);
      expect(result, startsWith('Hôm nay'));
    });

    test('returns "Hôm qua" for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = DateFormatter.formatRelative(yesterday);
      expect(result, startsWith('Hôm qua'));
    });

    test('returns "X ngày trước" for dates within 7 days', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final result = DateFormatter.formatRelative(threeDaysAgo);
      expect(result, '3 ngày trước');
    });

    test('returns short format for dates older than 7 days', () {
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      final result = DateFormatter.formatRelative(tenDaysAgo);
      expect(result, matches(RegExp(r'\d{2}/\d{2}/\d{4}')));
    });
  });

  group('DateFormatter.formatFull', () {
    test('returns full date format', () {
      final date = DateTime(2026, 5, 17);
      final result = DateFormatter.formatFull(date);
      expect(result, contains('17'));
      expect(result, contains('2026'));
    });
  });

  group('DateFormatter.formatShort', () {
    test('returns dd/MM/yyyy format', () {
      final date = DateTime(2026, 5, 17);
      expect(DateFormatter.formatShort(date), '17/05/2026');
    });
  });

  group('DateFormatter.formatTime', () {
    test('returns HH:mm format', () {
      final date = DateTime(2026, 5, 17, 14, 30);
      expect(DateFormatter.formatTime(date), '14:30');
    });
  });

  group('DateFormatter.formatDayGroup', () {
    test('returns "Hôm nay" for today', () {
      final today = DateTime.now();
      expect(DateFormatter.formatDayGroup(today), 'Hôm nay');
    });

    test('returns "Hôm qua" for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.formatDayGroup(yesterday), 'Hôm qua');
    });
  });
}
