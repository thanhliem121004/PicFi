import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/expense_entity.dart';

const int _pageSize = 20;

// ═══════════ STATE ═══════════
class ExpenseState extends Equatable {
  final List<ExpenseEntity> expenses;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final double totalIncome;
  final double totalExpense;
  final bool hasMore;

  const ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.hasMore = true,
  });

  double get balance => totalIncome - totalExpense;

  ExpenseState copyWith({
    List<ExpenseEntity>? expenses,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    double? totalIncome,
    double? totalExpense,
    bool? hasMore,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [expenses, isLoading, isLoadingMore, error, totalIncome, totalExpense, hasMore];
}

// ═══════════ CUBIT ═══════════
class ExpenseCubit extends Cubit<ExpenseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _expenseSub;
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  ExpenseCubit() : super(const ExpenseState()) {
    _listenToExpenses();
  }

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _expensesRef =>
      _firestore.collection('users').doc(_uid).collection('expenses');

  void _listenToExpenses() {
    _auth.authStateChanges().listen((user) {
      _expenseSub?.cancel();
      _lastDoc = null;
      _hasMore = true;
      if (user != null) {
        emit(state.copyWith(isLoading: true, hasMore: true));
        _fetchIncome(user.uid);
        _expenseSub = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('expenses')
            .orderBy('date', descending: true)
            .limit(_pageSize)
            .snapshots()
            .listen((snapshot) {
          final docs = snapshot.docs;
          _lastDoc = docs.isNotEmpty ? docs.last : null;
          _hasMore = docs.length >= _pageSize;
          final expenses = docs.map((doc) {
            final data = doc.data();
            return ExpenseEntity(
              id: doc.id,
              userId: user.uid,
              amount: (data['amount'] as num).toDouble(),
              category: data['category'] ?? 'other',
              note: data['note'],
              date: (data['date'] as Timestamp).toDate(),
              imageUrl: data['imageUrl'],
              location: data['location'],
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();

          final totalExpense = expenses.fold<double>(0, (sum, e) => sum + e.amount);

          emit(state.copyWith(
            expenses: expenses,
            totalExpense: totalExpense,
            isLoading: false,
            hasMore: _hasMore,
          ));
        });
      } else {
        emit(const ExpenseState());
      }
    });
  }

  Future<void> loadMoreExpenses() async {
    if (_uid == null || !_hasMore || state.isLoadingMore || _lastDoc == null) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(_pageSize)
          .get();
      final docs = snapshot.docs;
      _lastDoc = docs.isNotEmpty ? docs.last : null;
      _hasMore = docs.length >= _pageSize;
      final newExpenses = docs.map((doc) {
        final data = doc.data();
        return ExpenseEntity(
          id: doc.id,
          userId: _uid!,
          amount: (data['amount'] as num).toDouble(),
          category: data['category'] ?? 'other',
          note: data['note'],
          date: (data['date'] as Timestamp).toDate(),
          imageUrl: data['imageUrl'],
          location: data['location'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      final allExpenses = [...state.expenses, ...newExpenses];
      final totalExpense = allExpenses.fold<double>(0, (sum, e) => sum + e.amount);
      emit(state.copyWith(
        expenses: allExpenses,
        totalExpense: totalExpense,
        isLoadingMore: false,
        hasMore: _hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: 'Lỗi tải thêm: $e'));
    }
  }

  Future<void> _fetchIncome(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).collection('settings').doc('income').get();
      if (doc.exists) {
        final income = (doc.data()?['amount'] as num?)?.toDouble() ?? 0;
        emit(state.copyWith(totalIncome: income));
      } else {
        emit(state.copyWith(totalIncome: 0));
      }
    } catch (_) {
      emit(state.copyWith(totalIncome: 0));
    }
  }

  Future<void> addExpense(ExpenseEntity expense) async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      await _expensesRef.add({
        'amount': expense.amount,
        'category': expense.category,
        'note': expense.note,
        'date': Timestamp.fromDate(expense.date),
        'imageUrl': expense.imageUrl,
        'location': expense.location,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi thêm chi tiêu: $e'));
    }
  }

  Future<void> deleteExpense(String id) async {
    if (_uid == null) return;
    try {
      await _expensesRef.doc(id).delete();
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi xóa chi tiêu: $e'));
    }
  }

  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    if (_uid == null) return;
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _expensesRef.doc(id).update(data);
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi cập nhật: $e'));
    }
  }

  /// Chia sẻ chi tiêu lên bảng tin (feed) để bạn bè xem
  Future<void> shareToFeed({
    required double amount,
    required String category,
    String? note,
    String? emoji,
    String? imageUrl,
  }) async {
    if (_uid == null) return;
    try {
      final userDoc = await _firestore.collection('users').doc(_uid).get();
      final userData = userDoc.data() ?? {};

      await _firestore.collection('feed').add({
        'userId': _uid,
        'userName': userData['displayName'] ?? 'Người dùng PicFi',
        'userPicfiId': userData['picfiId'] ?? '',
        'userPhotoUrl': userData['photoUrl'],
        'amount': amount,
        'category': category,
        'note': note,
        'emoji': emoji ?? '💸',
        'imageUrl': imageUrl,
        'likes': 0,
        'sharedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi chia sẻ: $e'));
    }
  }

  List<ExpenseEntity> getExpensesByCategory(String category) {
    if (category == 'all') return state.expenses;
    return state.expenses.where((e) => e.category == category).toList();
  }

  Map<String, double> getCategoryStats() {
    final stats = <String, double>{};
    for (final expense in state.expenses) {
      stats[expense.category] = (stats[expense.category] ?? 0) + expense.amount;
    }
    return stats;
  }

  Map<String, List<ExpenseEntity>> getGroupedByDate() {
    final grouped = <String, List<ExpenseEntity>>{};
    for (final expense in state.expenses) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
      final diff = today.difference(expDate).inDays;

      String key;
      if (diff == 0) {
        key = 'Hôm nay';
      } else if (diff == 1) {
        key = 'Hôm qua';
      } else {
        key = '$diff ngày trước';
      }

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(expense);
    }
    return grouped;
  }

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true));
    _expenseSub?.cancel();
    _lastDoc = null;
    _hasMore = true;
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _fetchIncome(uid);
      _expenseSub = _firestore
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .limit(_pageSize)
          .snapshots()
          .listen((snapshot) {
        final docs = snapshot.docs;
        _lastDoc = docs.isNotEmpty ? docs.last : null;
        _hasMore = docs.length >= _pageSize;
        final expenses = docs.map((doc) {
          final data = doc.data();
          return ExpenseEntity(
            id: doc.id,
            userId: uid,
            amount: (data['amount'] as num).toDouble(),
            category: data['category'] ?? 'other',
            note: data['note'],
            date: (data['date'] as Timestamp).toDate(),
            imageUrl: data['imageUrl'],
            location: data['location'],
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();

        final totalExpense = expenses.fold<double>(0, (sum, e) => sum + e.amount);

        emit(state.copyWith(
          expenses: expenses,
          totalExpense: totalExpense,
          isLoading: false,
          hasMore: _hasMore,
        ));
      });
    } else {
      emit(const ExpenseState());
    }
  }

  @override
  Future<void> close() {
    _expenseSub?.cancel();
    return super.close();
  }
}
