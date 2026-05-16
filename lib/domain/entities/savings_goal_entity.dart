import 'package:equatable/equatable.dart';

class SavingsGoalEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final DateTime createdAt;
  final String? emoji;
  final String? icon;

  const SavingsGoalEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    required this.createdAt,
    this.emoji,
    this.icon,
  });

  double get progressPercent =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get remainingAmount => targetAmount - currentAmount;

  SavingsGoalEntity copyWith({
    String? id,
    String? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    DateTime? createdAt,
    String? emoji,
    String? icon,
  }) {
    return SavingsGoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      emoji: emoji ?? this.emoji,
      icon: icon ?? this.icon,
    );
  }

  factory SavingsGoalEntity.fromMap(Map<String, dynamic> data, String docId) {
    return SavingsGoalEntity(
      id: docId,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0,
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0,
      deadline: (data['deadline'] as dynamic)?.toDate(),
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      emoji: data['emoji'] as String?,
      icon: data['icon'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline,
      'createdAt': createdAt,
      'emoji': emoji,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [
        id, userId, name, targetAmount, currentAmount,
        deadline, createdAt, emoji, icon,
      ];
}
