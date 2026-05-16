import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/savings_goal_entity.dart';

class SavingsGoalState extends Equatable {
  final List<SavingsGoalEntity> goals;
  final bool isLoading;
  final String? error;

  const SavingsGoalState({
    this.goals = const [],
    this.isLoading = false,
    this.error,
  });

  SavingsGoalState copyWith({
    List<SavingsGoalEntity>? goals,
    bool? isLoading,
    String? error,
  }) {
    return SavingsGoalState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [goals, isLoading, error];
}

class SavingsGoalCubit extends Cubit<SavingsGoalState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _goalsSub;

  SavingsGoalCubit() : super(const SavingsGoalState()) {
    _listenToGoals();
  }

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _goalsRef =>
      _firestore.collection('users').doc(_uid).collection('savings_goals');

  void _listenToGoals() {
    _auth.authStateChanges().listen((user) {
      _goalsSub?.cancel();
      if (user != null) {
        _goalsSub = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('savings_goals')
            .snapshots()
            .listen((snapshot) {
          final goals = snapshot.docs.map((doc) {
            final data = doc.data();
            return SavingsGoalEntity.fromMap(data, doc.id);
          }).toList();
          if (!isClosed) emit(state.copyWith(goals: goals, isLoading: false));
        }, onError: (e) {
          if (!isClosed) emit(state.copyWith(error: 'Lỗi tải mục tiêu: $e'));
        });
      } else {
        if (!isClosed) emit(const SavingsGoalState());
      }
    });
  }

  Future<void> addGoal(SavingsGoalEntity goal) async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      await _goalsRef.add(goal.toMap());
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi thêm mục tiêu: $e'));
    }
  }

  Future<void> updateGoal(String id, Map<String, dynamic> data) async {
    if (_uid == null) return;
    try {
      await _goalsRef.doc(id).update(data);
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi cập nhật mục tiêu: $e'));
    }
  }

  Future<void> deleteGoal(String id) async {
    if (_uid == null) return;
    try {
      await _goalsRef.doc(id).delete();
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi xóa mục tiêu: $e'));
    }
  }

  Future<void> contribute(String id, double amount) async {
    if (_uid == null) return;
    try {
      final doc = await _goalsRef.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final current = (data?['currentAmount'] as num?)?.toDouble() ?? 0;
        final target = (data?['targetAmount'] as num?)?.toDouble() ?? 0;
        final newAmount = current + amount;
        final updates = <String, dynamic>{'currentAmount': newAmount};
        if (newAmount >= target) {
          updates['isCompleted'] = true;
        }
        await _goalsRef.doc(id).update(updates);
      }
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi nạp tiền: $e'));
    }
  }

  @override
  Future<void> close() {
    _goalsSub?.cancel();
    return super.close();
  }
}
