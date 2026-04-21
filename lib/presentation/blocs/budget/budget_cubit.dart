import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/budget_entity.dart';

class BudgetState extends Equatable {
  final List<BudgetEntity> budgets;
  final bool isLoading;
  final String? error;

  const BudgetState({
    this.budgets = const [],
    this.isLoading = false,
    this.error,
  });

  double get totalSpent => budgets.fold(0, (sum, b) => sum + b.currentSpent);
  double get totalLimit => budgets.fold(0, (sum, b) => sum + b.monthlyLimit);

  @override
  List<Object?> get props => [budgets, isLoading, error];
}

class BudgetCubit extends Cubit<BudgetState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _budgetSub;

  BudgetCubit() : super(const BudgetState()) {
    _auth.authStateChanges().listen((user) {
      _budgetSub?.cancel();
      if (user != null) {
        _listenToBudgets(user.uid);
      } else {
        emit(const BudgetState());
      }
    });
  }

  String? get _uid => _auth.currentUser?.uid;

  void _listenToBudgets(String uid) {
    final now = DateTime.now();
    _budgetSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .where('month', isEqualTo: now.month)
        .where('year', isEqualTo: now.year)
        .snapshots()
        .listen((snapshot) {
      final budgets = snapshot.docs.map((doc) {
        final d = doc.data();
        return BudgetEntity(
          id: doc.id,
          userId: uid,
          category: d['category'] ?? 'other',
          monthlyLimit: (d['monthlyLimit'] as num).toDouble(),
          month: d['month'] ?? now.month,
          year: d['year'] ?? now.year,
          currentSpent: (d['currentSpent'] as num?)?.toDouble() ?? 0,
          updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      emit(BudgetState(budgets: budgets));
    });
  }

  Future<void> addBudget(String category, double limit) async {
    if (_uid == null) return;
    final now = DateTime.now();
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('budgets')
          .add({
        'category': category,
        'monthlyLimit': limit,
        'month': now.month,
        'year': now.year,
        'currentSpent': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(BudgetState(budgets: state.budgets, error: 'Lỗi thêm ngân sách: $e'));
    }
  }

  Future<void> updateBudgetLimit(String id, double newLimit) async {
    if (_uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('budgets')
          .doc(id)
          .update({
        'monthlyLimit': newLimit,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(BudgetState(budgets: state.budgets, error: 'Lỗi cập nhật: $e'));
    }
  }

  Future<void> deleteBudget(String id) async {
    if (_uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('budgets')
          .doc(id)
          .delete();
    } catch (e) {
      emit(BudgetState(budgets: state.budgets, error: 'Lỗi xóa: $e'));
    }
  }

  @override
  Future<void> close() {
    _budgetSub?.cancel();
    return super.close();
  }
}
