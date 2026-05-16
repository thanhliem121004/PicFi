import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double balance;
  final String currency;
  final String icon;
  final int color;
  final bool isDefault;
  final DateTime createdAt;

  const WalletEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.balance = 0,
    this.currency = 'VND',
    this.icon = '💳',
    this.color = 0xFF006A65,
    this.isDefault = false,
    required this.createdAt,
  });

  int get colorValue => color;

  WalletEntity copyWith({
    String? id,
    String? userId,
    String? name,
    double? balance,
    String? currency,
    String? icon,
    int? color,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return WalletEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory WalletEntity.fromMap(Map<String, dynamic> data, String docId) {
    final colorVal = data['color'] as int? ?? data['colorValue'] as int? ?? 0xFF006A65;
    return WalletEntity(
      id: docId,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      balance: (data['balance'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? 'VND',
      icon: data['icon'] as String? ?? '💳',
      color: colorVal,
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'balance': balance,
      'currency': currency,
      'icon': icon,
      'color': color,
      'colorValue': color,
      'isDefault': isDefault,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id, userId, name, balance, currency,
        icon, color, isDefault, createdAt,
      ];
}
