import 'package:flutter/material.dart';

class ExpenseOverlayConfig {
  final double left;
  final double top;
  final double opacity;
  final double fontSize;
  final Color color;
  final bool bold;
  final bool shadow;

  const ExpenseOverlayConfig({
    this.left = 0.05,
    this.top = 0.65,
    this.opacity = 1.0,
    this.fontSize = 28,
    this.color = Colors.white,
    this.bold = true,
    this.shadow = true,
  });

  int get colorValue => color.toARGB32();

  ExpenseOverlayConfig copyWith({
    double? left,
    double? top,
    double? opacity,
    double? fontSize,
    Color? color,
    int? colorValue,
    bool? bold,
    bool? shadow,
  }) {
    return ExpenseOverlayConfig(
      left: left ?? this.left,
      top: top ?? this.top,
      opacity: opacity ?? this.opacity,
      fontSize: fontSize ?? this.fontSize,
      color: colorValue != null ? Color(colorValue) : (color ?? this.color),
      bold: bold ?? this.bold,
      shadow: shadow ?? this.shadow,
    );
  }
}
