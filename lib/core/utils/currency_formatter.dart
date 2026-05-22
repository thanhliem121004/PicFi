import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat('#,###', 'vi');

  static const _rates = {'USD': 25000, 'VND': 1};

  static String _symbol(String currency) {
    switch (currency) {
      case 'USD': return 'USD';
      case 'VND': return 'đ';
      default: return currency;
    }
  }

  static String format(double amount, {String currency = 'VND'}) {
    final abs = amount.abs();
    if (currency == 'USD') {
      final usdAmount = abs / _rates['USD']!;
      return '\$${NumberFormat('#,###.##', 'en').format(usdAmount)}';
    }
    return '${_formatter.format(abs)} ${_symbol(currency)}';
  }

  static String formatWithSign(double amount, {String currency = 'VND'}) {
    final sign = amount >= 0 ? '+' : '-';
    if (currency == 'USD') {
      final usdAmount = amount.abs() / _rates['USD']!;
      return '$sign\$${NumberFormat('#,###.##', 'en').format(usdAmount)}';
    }
    return '$sign${_formatter.format(amount.abs())} ${_symbol(currency)}';
  }

  static String formatCompact(double amount, {String currency = 'VND'}) {
    if (currency == 'USD') {
      final usdAmount = amount.abs() / _rates['USD']!;
      return '\$${NumberFormat('#,###.##', 'en').format(usdAmount)}';
    }
    return '${_formatter.format(amount.abs())}${_symbol(currency)}';
  }

  static String formatShort(double amount, {String currency = 'VND'}) {
    final abs = amount.abs();
    if (currency == 'USD') {
      final usdAmount = abs / _rates['USD']!;
      if (usdAmount >= 1000000) return '\$${(usdAmount / 1000000).toStringAsFixed(1)}M';
      if (usdAmount >= 1000) return '\$${(usdAmount / 1000).toStringAsFixed(0)}K';
      return '\$${usdAmount.toStringAsFixed(2)}';
    }
    if (abs >= 1000000) return '${(abs / 1000000).toStringAsFixed(1)}M ${_symbol(currency)}';
    if (abs >= 1000) return '${(abs / 1000).toStringAsFixed(0)}K ${_symbol(currency)}';
    return '${_formatter.format(abs)} ${_symbol(currency)}';
  }

  static String formatOverlay(double amount, {String currency = 'VND'}) {
    return formatShort(amount, currency: currency);
  }

  static double convertToVND(double amount, String fromCurrency) {
    final rate = _rates[fromCurrency] ?? 1;
    return amount * rate;
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
