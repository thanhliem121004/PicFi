import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/achievement_entity.dart';

class GamificationState extends Equatable {
  final List<AchievementEntity> achievements;
  final bool isLoading;

  const GamificationState({
    this.achievements = const [],
    this.isLoading = false,
  });

  int get unlockedCount => achievements.where((a) => a.unlocked).length;
  int get totalCount => achievements.length;

  GamificationState copyWith({
    List<AchievementEntity>? achievements,
    bool? isLoading,
  }) {
    return GamificationState(
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [achievements, isLoading];
}

class GamificationCubit extends Cubit<GamificationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GamificationCubit() : super(const GamificationState()) {
    _initAchievements();
  }

  String? get _uid => _auth.currentUser?.uid;

  Future<void> _initAchievements() async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('achievements')
          .doc('data')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final list = (data['list'] as List<dynamic>?) ?? [];
        final achievements = list.map((e) =>
            AchievementEntity.fromMap(e as Map<String, dynamic>)).toList();
        emit(state.copyWith(achievements: achievements, isLoading: false));
      } else {
        await _saveAchievements(defaultAchievements);
        emit(state.copyWith(achievements: defaultAchievements, isLoading: false));
      }
    } catch (_) {
      emit(state.copyWith(achievements: defaultAchievements, isLoading: false));
    }
  }

  Future<void> _saveAchievements(List<AchievementEntity> achievements) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('achievements')
        .doc('data')
        .set({'list': achievements.map((a) => a.toMap()).toList()});
  }

  Future<void> checkAndUpdate({
    int? expenseCount,
    int? friendCount,
    int? streak,
    int? walletCount,
    bool? hasReport,
    bool? hasSavingsGoal,
    bool? hasSplit,
  }) async {
    final updated = state.achievements.map((a) {
      var ach = a;
      switch (a.id) {
        case 'first_expense':
          if (expenseCount != null && expenseCount >= 1 && !ach.unlocked) {
            ach = ach.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }
          break;
        case 'ten_expenses':
          if (expenseCount != null) {
            final prog = expenseCount.clamp(0, 10);
            ach = ach.copyWith(progress: prog, unlocked: prog >= 10);
            if (prog >= 10 && !a.unlocked) ach = ach.copyWith(unlockedAt: DateTime.now());
          }
          break;
        case 'fifty_expenses':
          if (expenseCount != null) {
            final prog = expenseCount.clamp(0, 50);
            ach = ach.copyWith(progress: prog, unlocked: prog >= 50);
            if (prog >= 50 && !a.unlocked) ach = ach.copyWith(unlockedAt: DateTime.now());
          }
          break;
        case 'hundred_expenses':
          if (expenseCount != null) {
            final prog = expenseCount.clamp(0, 100);
            ach = ach.copyWith(progress: prog, unlocked: prog >= 100);
            if (prog >= 100 && !a.unlocked) ach = ach.copyWith(unlockedAt: DateTime.now());
          }
          break;
        case 'first_friend':
          if (friendCount != null && friendCount >= 1 && !ach.unlocked) {
            ach = ach.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }
          break;
        case 'five_friends':
          if (friendCount != null) {
            final prog = friendCount.clamp(0, 5);
            ach = ach.copyWith(progress: prog, unlocked: prog >= 5);
            if (prog >= 5 && !a.unlocked) ach = ach.copyWith(unlockedAt: DateTime.now());
          }
          break;
        case 'streak_7':
          if (streak != null) {
            final prog = streak.clamp(0, 7);
            ach = ach.copyWith(progress: prog, unlocked: prog >= 7);
            if (prog >= 7 && !a.unlocked) ach = ach.copyWith(unlockedAt: DateTime.now());
          }
          break;
        case 'streak_30':
          if (streak != null) {
            final prog = streak.clamp(0, 30);
            ach = ach.copyWith(progress: prog, unlocked: prog >= 30);
            if (prog >= 30 && !a.unlocked) ach = ach.copyWith(unlockedAt: DateTime.now());
          }
          break;
        case 'savings_goal':
          if (hasSavingsGoal == true && !ach.unlocked) {
            ach = ach.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }
          break;
        case 'five_wallets':
          if (walletCount != null) {
            final prog = walletCount.clamp(0, 5);
            ach = ach.copyWith(progress: prog, unlocked: prog >= 5);
            if (prog >= 5 && !a.unlocked) ach = ach.copyWith(unlockedAt: DateTime.now());
          }
          break;
        case 'report_first':
          if (hasReport == true && !ach.unlocked) {
            ach = ach.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }
          break;
        case 'split_first':
          if (hasSplit == true && !ach.unlocked) {
            ach = ach.copyWith(progress: 1, unlocked: true, unlockedAt: DateTime.now());
          }
          break;
      }
      return ach;
    }).toList();

    emit(state.copyWith(achievements: updated));
    await _saveAchievements(updated);
  }
}
