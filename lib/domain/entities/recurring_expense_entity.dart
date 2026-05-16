import 'package:equatable/equatable.dart';

enum RecurringInterval { daily, weekly, monthly, yearly }

class RecurringExpenseEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String? note;
  final RecurringInterval interval;
  final DateTime startDate;
  final DateTime? nextDueDate;
  final DateTime? endDate;
  final bool isActive;

  const RecurringExpenseEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    this.note,
    required this.interval,
    required this.startDate,
    this.nextDueDate,
    this.endDate,
    this.isActive = true,
  });

  String get intervalLabel {
    switch (interval) {
      case RecurringInterval.daily:
        return 'Hàng ngày';
      case RecurringInterval.weekly:
        return 'Hàng tuần';
      case RecurringInterval.monthly:
        return 'Hàng tháng';
      case RecurringInterval.yearly:
        return 'Hàng năm';
    }
  }

  DateTime getNextOccurrence() {
    final base = nextDueDate ?? startDate;
    switch (interval) {
      case RecurringInterval.daily:
        return base.add(const Duration(days: 1));
      case RecurringInterval.weekly:
        return base.add(const Duration(days: 7));
      case RecurringInterval.monthly:
        return DateTime(base.year, base.month + 1, base.day);
      case RecurringInterval.yearly:
        return DateTime(base.year + 1, base.month, base.day);
    }
  }

  RecurringExpenseEntity copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? note,
    RecurringInterval? interval,
    DateTime? startDate,
    DateTime? nextDueDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return RecurringExpenseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      interval: interval ?? this.interval,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  factory RecurringExpenseEntity.fromMap(Map<String, dynamic> data, String docId) {
    return RecurringExpenseEntity(
      id: docId,
      userId: data['userId'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: data['category'] ?? '',
      note: data['note'] as String?,
      interval: RecurringInterval.values.firstWhere(
        (e) => e.name == data['interval'],
        orElse: () => RecurringInterval.monthly,
      ),
      startDate: (data['startDate'] as dynamic)?.toDate() ?? DateTime.now(),
      nextDueDate: (data['nextDueDate'] as dynamic)?.toDate(),
      endDate: (data['endDate'] as dynamic)?.toDate(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'category': category,
      'note': note,
      'interval': interval.name,
      'startDate': startDate,
      'nextDueDate': nextDueDate ?? startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id, userId, amount, category, note,
        interval, startDate, nextDueDate, endDate, isActive,
      ];
}
