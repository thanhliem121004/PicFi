import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/recurring_expense_entity.dart';

class RecurringState extends Equatable {
  final List<RecurringExpenseEntity> recurringExpenses;
  final bool isLoading;
  final String? error;

  const RecurringState({
    this.recurringExpenses = const [],
    this.isLoading = false,
    this.error,
  });

  RecurringState copyWith({
    List<RecurringExpenseEntity>? recurringExpenses,
    bool? isLoading,
    String? error,
  }) {
    return RecurringState(
      recurringExpenses: recurringExpenses ?? this.recurringExpenses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [recurringExpenses, isLoading, error];
}

class RecurringCubit extends Cubit<RecurringState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _recurringSub;
  Timer? _checkTimer;

  RecurringCubit() : super(const RecurringState()) {
    _listenToRecurring();
    _startAutoCheck();
  }

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _recurringRef =>
      _firestore.collection('users').doc(_uid).collection('recurring');

  void _listenToRecurring() {
    _auth.authStateChanges().listen((user) {
      _recurringSub?.cancel();
      if (user != null) {
        _recurringSub = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('recurring')
            .orderBy('nextDueDate', descending: false)
            .snapshots()
            .listen((snapshot) {
          final recurring = snapshot.docs.map((doc) {
            final data = doc.data();
            return RecurringExpenseEntity.fromMap(data, doc.id);
          }).toList();
          if (!isClosed) emit(state.copyWith(recurringExpenses: recurring, isLoading: false));
        }, onError: (e) {
          if (!isClosed) emit(state.copyWith(error: 'Lỗi tải chi tiêu định kỳ: $e'));
        });
      } else {
        if (!isClosed) emit(const RecurringState());
      }
    });
  }

  void _startAutoCheck() {
    _checkTimer = Timer.periodic(const Duration(hours: 1), (_) => _checkDue());
    _checkTimer = Timer.periodic(const Duration(minutes: 5), (_) => _checkDue());
  }

  Future<void> _checkDue() async {
    if (_uid == null) return;
    final now = DateTime.now();
    final dueItems = state.recurringExpenses.where((r) {
      if (!r.isActive || r.nextDueDate == null) return false;
      return r.nextDueDate!.isBefore(now) || r.nextDueDate!.isAtSameMomentAs(now);
    });
    for (final item in dueItems) {
      await _firestore.collection('users').doc(_uid).collection('expenses').add({
        'amount': item.amount,
        'category': item.category,
        'note': '[Định kỳ] ${item.note ?? item.category}',
        'date': Timestamp.fromDate(now),
        'type': 'expense',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final nextDate = item.getNextOccurrence();
      await _recurringRef.doc(item.id).update({
        'nextDueDate': nextDate.millisecondsSinceEpoch,
      });
    }
  }

  Future<void> addRecurring(RecurringExpenseEntity recurring) async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      await _recurringRef.add(recurring.toMap());
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi thêm chi tiêu định kỳ: $e'));
    }
  }

  Future<void> updateRecurring(String id, Map<String, dynamic> data) async {
    if (_uid == null) return;
    try {
      await _recurringRef.doc(id).update(data);
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi cập nhật: $e'));
    }
  }

  Future<void> deleteRecurring(String id) async {
    if (_uid == null) return;
    try {
      await _recurringRef.doc(id).delete();
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi xóa: $e'));
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await updateRecurring(id, {'isActive': isActive});
  }

  @override
  Future<void> close() {
    _checkTimer?.cancel();
    _recurringSub?.cancel();
    return super.close();
  }
}
