import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final String? category;
  final double monthlyLimit;
  final int month;
  final int year;
  final double currentSpent;
  final DateTime updatedAt;

  const BudgetEntity({
    required this.id,
    required this.userId,
    this.category,
    required this.monthlyLimit,
    required this.month,
    required this.year,
    required this.currentSpent,
    required this.updatedAt,
  });

  double get usedPercent =>
      monthlyLimit > 0 ? (currentSpent / monthlyLimit * 100).clamp(0, 999) : 0;

  double get remainingAmount => monthlyLimit - currentSpent;

  bool get isOverBudget => currentSpent > monthlyLimit;

  bool get isNearLimit => usedPercent >= 80 && !isOverBudget;

  BudgetEntity copyWith({
    String? id,
    String? userId,
    String? category,
    double? monthlyLimit,
    int? month,
    int? year,
    double? currentSpent,
    DateTime? updatedAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      month: month ?? this.month,
      year: year ?? this.year,
      currentSpent: currentSpent ?? this.currentSpent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, category, monthlyLimit, month, year, currentSpent];
}
