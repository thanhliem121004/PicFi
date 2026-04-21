import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String? note;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? localImagePath;
  final String? location;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    this.note,
    this.imageUrl,
    this.thumbnailUrl,
    this.localImagePath,
    this.location,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  ExpenseEntity copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? note,
    String? imageUrl,
    String? thumbnailUrl,
    String? localImagePath,
    String? location,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      location: location ?? this.location,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, amount, category, note,
        imageUrl, thumbnailUrl, localImagePath,
        location, date, createdAt, updatedAt,
      ];
}
