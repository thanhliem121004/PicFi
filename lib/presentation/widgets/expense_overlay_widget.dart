import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/expense_entity.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/constants/expense_categories.dart';

/// Widget overlay chi tiêu hiển thị lên ảnh — giống Locket
/// Dùng chung cho: add_expense_screen, feed_screen, expense_detail, home_screen
class ExpenseOverlayWidget extends StatelessWidget {
  final double amount;
  final String? category;
  final String? note;
  final String? emoji;
  final ExpenseOverlayConfig? config;
  final String? overlayText;
  final bool showDate;
  final bool showCategory;

  const ExpenseOverlayWidget({
    super.key,
    required this.amount,
    this.category,
    this.note,
    this.emoji,
    this.config,
    this.overlayText,
    this.showDate = false,
    this.showCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = config ?? const ExpenseOverlayConfig();
    final text = overlayText ?? CurrencyFormatter.formatOverlay(amount);

    String? subtitle;
    if (showCategory && category != null) {
      final cat = ExpenseCategory.values.firstWhere(
        (c) => c.name == category,
        orElse: () => ExpenseCategory.other,
      );
      subtitle = cat.label;
    } else if (note != null && note!.isNotEmpty) {
      subtitle = note;
    }

    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final left = constraints.maxWidth * cfg.left;
          final top  = constraints.maxHeight * cfg.top;

          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                child: Opacity(
                  opacity: cfg.opacity,
                  child: _OverlayText(
                    amount: text,
                    subtitle: subtitle,
                    emoji: emoji,
                    fontSize: cfg.fontSize,
                    color: cfg.color,
                    bold: cfg.bold,
                    shadow: cfg.shadow,
                    showDate: showDate,
                    date: DateTime.now(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OverlayText extends StatelessWidget {
  final String amount;
  final String? subtitle;
  final String? emoji;
  final double fontSize;
  final Color color;
  final bool bold;
  final bool shadow;
  final bool showDate;
  final DateTime date;

  const _OverlayText({
    required this.amount,
    this.subtitle,
    this.emoji,
    required this.fontSize,
    required this.color,
    required this.bold,
    required this.shadow,
    required this.showDate,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (emoji != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(emoji!, style: TextStyle(fontSize: fontSize * 1.2)),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            amount,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
              color: color,
              letterSpacing: -0.5,
              shadows: shadow
                  ? [
                      const Shadow(color: Colors.black38, blurRadius: 8, offset: Offset(1, 2)),
                      Shadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4)),
                    ]
                  : null,
            ),
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: fontSize * 0.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  shadows: shadow
                      ? [const Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 1))]
                      : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        if (showDate)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: fontSize * 0.42,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.7),
                shadows: shadow
                    ? [const Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1))]
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

/// Preview widget để xem trước overlay trong editor
class ExpenseOverlayPreview extends StatelessWidget {
  final String imagePath;
  final double amount;
  final String? category;
  final String? note;
  final String? emoji;
  final ExpenseOverlayConfig config;

  const ExpenseOverlayPreview({
    super.key,
    required this.imagePath,
    required this.amount,
    this.category,
    this.note,
    this.emoji,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, size: 64),
          ),
        ),
        ExpenseOverlayWidget(
          amount: amount,
          category: category,
          note: note,
          emoji: emoji,
          config: config,
        ),
      ],
    );
  }
}
