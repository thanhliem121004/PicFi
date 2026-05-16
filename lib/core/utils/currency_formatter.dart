import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat('#,###', 'vi');

  static String format(double amount) {
    return '${_formatter.format(amount.abs())} đ';
  }

  static String formatWithSign(double amount) {
    final sign = amount >= 0 ? '+' : '-';
    return '$sign${_formatter.format(amount.abs())} đ';
  }

  static String formatCompact(double amount) {
    return '${_formatter.format(amount.abs())}đ';
  }

  static String formatShort(double amount) {
    final abs = amount.abs();
    if (abs >= 1000000) return '${(abs / 1000000).toStringAsFixed(1)}M đ';
    if (abs >= 1000) return '${(abs / 1000).toStringAsFixed(0)}K đ';
    return '${abs.toStringAsFixed(0)} đ';
  }

  static String formatOverlay(double amount) {
    final abs = amount.abs();
    if (abs >= 1000000) return '${(abs / 1000000).toStringAsFixed(1)}M đ';
    if (abs >= 1000) return '${(abs / 1000).toStringAsFixed(0)}K đ';
    return '${abs.toStringAsFixed(0)} đ';
  }

  static double? parse(String text) {
    try {
      String cleaned = text.replaceAll('đ', '').replaceAll('₫', '').trim();
      if (cleaned.contains(',')) {
        cleaned = cleaned.replaceAll('.', '');
        cleaned = cleaned.replaceAll(',', '.');
      } else {
        cleaned = cleaned.replaceAll('.', '');
      }
      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }
}
