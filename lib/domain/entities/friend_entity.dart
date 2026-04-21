import 'package:equatable/equatable.dart';

class FriendEntity extends Equatable {
  final String id;
  final String friendId;
  final String friendName;
  final String? friendPhotoUrl;
  final String? friendEmail;
  final int streak;
  final DateTime? lastInteraction;
  final FriendStatus status;
  final DateTime createdAt;

  const FriendEntity({
    required this.id,
    required this.friendId,
    required this.friendName,
    this.friendPhotoUrl,
    this.friendEmail,
    this.streak = 0,
    this.lastInteraction,
    required this.status,
    required this.createdAt,
  });

  bool get isStreakActive {
    if (lastInteraction == null) return false;
    final diff = DateTime.now().difference(lastInteraction!);
    return diff.inHours < 24;
  }

  @override
  List<Object?> get props => [
        id, friendId, friendName, friendPhotoUrl,
        streak, lastInteraction, status, createdAt,
      ];
}

enum FriendStatus {
  pending,
  accepted,
  declined,
}
