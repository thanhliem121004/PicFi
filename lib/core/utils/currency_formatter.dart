import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat('#,###', 'vi_VN');

  /// Format number to Vietnamese dong: 150000 → 150.000 đ
  static String format(double amount) {
    return '${_formatter.format(amount.abs())} đ';
  }

  /// Format with sign: 150000 → -150.000 đ
  static String formatWithSign(double amount) {
    final sign = amount >= 0 ? '+' : '-';
    return '$sign${_formatter.format(amount.abs())} đ';
  }

  /// Short format for large numbers: 12450000 → 12.450.000 đ
  static String formatCompact(double amount) {
    return '${_formatter.format(amount.abs())}đ';
  }

  /// Short format: 1500000 → 1.5M, 250000 → 250K
  static String formatShort(double amount) {
    final abs = amount.abs();
    if (abs >= 1000000) {
      return '${(abs / 1000000).toStringAsFixed(1)}M đ';
    } else if (abs >= 1000) {
      return '${(abs / 1000).toStringAsFixed(0)}K đ';
    }
    return '${abs.toStringAsFixed(0)} đ';
  }

  /// Parse "150.000" → 150000.0
  static double? parse(String text) {
    try {
      final cleaned = text.replaceAll('.', '').replaceAll(',', '').replaceAll('đ', '').trim();
      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }
}
