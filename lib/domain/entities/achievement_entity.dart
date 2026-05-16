import 'package:equatable/equatable.dart';

class AchievementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int progress;
  final int maxProgress;
  final bool unlocked;
  final DateTime? unlockedAt;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.progress = 0,
    this.maxProgress = 1,
    this.unlocked = false,
    this.unlockedAt,
  });

  double get percentage => maxProgress > 0 ? progress / maxProgress : 0;

  AchievementEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? progress,
    int? maxProgress,
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'progress': progress,
    'maxProgress': maxProgress,
    'unlocked': unlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory AchievementEntity.fromMap(Map<String, dynamic> map) {
    return AchievementEntity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '🏆',
      progress: (map['progress'] as num?)?.toInt() ?? 0,
      maxProgress: (map['maxProgress'] as num?)?.toInt() ?? 1,
      unlocked: map['unlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null ? DateTime.tryParse(map['unlockedAt']) : null,
    );
  }

  @override
  List<Object?> get props => [id, title, description, icon, progress, maxProgress, unlocked, unlockedAt];
}

final List<AchievementEntity> defaultAchievements = [
  const AchievementEntity(id: 'first_expense', title: 'Khoảnh khắc đầu tiên', description: 'Ghi lại chi tiêu đầu tiên', icon: '🎯', maxProgress: 1),
  const AchievementEntity(id: 'ten_expenses', title: 'Chi tiêu thứ 10', description: 'Đạt 10 khoản chi tiêu', icon: '📸', maxProgress: 10),
  const AchievementEntity(id: 'fifty_expenses', title: 'Nhiếp ảnh gia tài chính', description: 'Đạt 50 khoản chi tiêu', icon: '🏅', maxProgress: 50),
  const AchievementEntity(id: 'hundred_expenses', title: 'Bậc thầy chi tiêu', description: 'Đạt 100 khoản chi tiêu', icon: '👑', maxProgress: 100),
  const AchievementEntity(id: 'first_friend', title: 'Kết nối đầu tiên', description: 'Kết bạn với người dùng khác', icon: '🤝', maxProgress: 1),
  const AchievementEntity(id: 'five_friends', title: 'Vòng kết nối', description: 'Có 5 người bạn', icon: '🌈', maxProgress: 5),
  const AchievementEntity(id: 'streak_7', title: '7 ngày liên tiếp', description: 'Duy trì streak 7 ngày', icon: '🔥', maxProgress: 7),
  const AchievementEntity(id: 'streak_30', title: 'Tháng rực lửa', description: 'Duy trì streak 30 ngày', icon: '💪', maxProgress: 30),
  const AchievementEntity(id: 'savings_goal', title: 'Mục tiêu đầu tiên', description: 'Hoàn thành mục tiêu tiết kiệm', icon: '💰', maxProgress: 1),
  const AchievementEntity(id: 'five_wallets', title: 'Đa ví', description: 'Tạo 5 ví khác nhau', icon: '👛', maxProgress: 5),
  const AchievementEntity(id: 'report_first', title: 'Báo cáo đầu tiên', description: 'Xuất báo cáo lần đầu', icon: '📊', maxProgress: 1),
  const AchievementEntity(id: 'split_first', title: 'Chia sẻ là quan tâm', description: 'Chia chi tiêu với bạn bè', icon: '🤲', maxProgress: 1),
];
