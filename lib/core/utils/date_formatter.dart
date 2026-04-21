import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatFull(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'vi').format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'vi').format(date);
  }

  static String formatMonthYearShort(DateTime date) {
    return 'Tháng ${date.month}, ${date.year}';
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hôm nay, ${formatTime(date)}';
    } else if (diff.inDays == 1) {
      return 'Hôm qua, ${formatTime(date)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return formatShort(date);
    }
  }

  static String formatDayGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly);

    if (diff.inDays == 0) return 'Hôm nay';
    if (diff.inDays == 1) return 'Hôm qua';
    return DateFormat('dd Thg MM', 'vi').format(date);
  }

  static String formatTransactionDate(DateTime date) {
    return 'Hôm nay, ${DateFormat('dd').format(date)} Thg ${DateFormat('MM').format(date)}';
  }
}
