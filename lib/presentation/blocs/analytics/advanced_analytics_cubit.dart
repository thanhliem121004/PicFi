import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/expense_entity.dart';

class CategoryTrend extends Equatable {
  final String category;
  final double amount;
  final double percentage;
  final int count;

  const CategoryTrend({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.count,
  });

  @override
  List<Object?> get props => [category, amount, percentage, count];
}

class MonthlyTrend extends Equatable {
  final String month;
  final double income;
  final double expense;

  const MonthlyTrend({
    required this.month,
    required this.income,
    required this.expense,
  });

  @override
  List<Object?> get props => [month, income, expense];
}

class AdvancedAnalyticsState extends Equatable {
  final List<MonthlyTrend> monthlyTrends;
  final List<CategoryTrend> categoryBreakdown;
  final double totalIncome;
  final double totalExpense;
  final double predictedNextMonth;
  final String? budgetRecommendation;
  final bool isLoading;
  final String? error;

  const AdvancedAnalyticsState({
    this.monthlyTrends = const [],
    this.categoryBreakdown = const [],
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.predictedNextMonth = 0,
    this.budgetRecommendation,
    this.isLoading = false,
    this.error,
  });

  AdvancedAnalyticsState copyWith({
    List<MonthlyTrend>? monthlyTrends,
    List<CategoryTrend>? categoryBreakdown,
    double? totalIncome,
    double? totalExpense,
    double? predictedNextMonth,
    String? budgetRecommendation,
    bool? isLoading,
    String? error,
  }) {
    return AdvancedAnalyticsState(
      monthlyTrends: monthlyTrends ?? this.monthlyTrends,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      predictedNextMonth: predictedNextMonth ?? this.predictedNextMonth,
      budgetRecommendation: budgetRecommendation ?? this.budgetRecommendation,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        monthlyTrends, categoryBreakdown, totalIncome, totalExpense,
        predictedNextMonth, budgetRecommendation, isLoading, error,
      ];
}

class AdvancedAnalyticsCubit extends Cubit<AdvancedAnalyticsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AdvancedAnalyticsCubit() : super(const AdvancedAnalyticsState());

  String? get _uid => _auth.currentUser?.uid;

  Future<void> loadAnalytics() async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true));

    try {
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

      final snap = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: sixMonthsAgo)
          .orderBy('date', descending: false)
          .get();

      final expenses = snap.docs.map((doc) {
        final data = doc.data();
        return ExpenseEntity(
          id: doc.id,
          userId: _uid!,
          amount: (data['amount'] as num).toDouble(),
          category: data['category'] ?? 'other',
          note: data['note'],
          date: (data['date'] as Timestamp).toDate(),
          imageUrl: data['imageUrl'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      final incomeDoc = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('settings')
          .doc('income')
          .get();
      final monthlyIncome = incomeDoc.exists
          ? (incomeDoc.data()?['amount'] as num?)?.toDouble() ?? 24000000.0
          : 24000000.0;

      final monthlyTrends = _calculateMonthlyTrends(expenses, monthlyIncome);
      final categoryBreakdown = _calculateCategoryBreakdown(expenses);

      final totalExpense = expenses.fold<double>(0, (acc, e) => acc + e.amount);
      final totalIncome = monthlyIncome * 6;

      final predicted = _predictNextMonth(monthlyTrends);

      final recommendation = _generateRecommendation(categoryBreakdown, totalExpense);

      emit(state.copyWith(
        monthlyTrends: monthlyTrends,
        categoryBreakdown: categoryBreakdown,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        predictedNextMonth: predicted,
        budgetRecommendation: recommendation,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi tải dữ liệu: $e'));
    }
  }

  List<MonthlyTrend> _calculateMonthlyTrends(List<ExpenseEntity> expenses, double monthlyIncome) {
    final grouped = <String, double>{};
    for (final expense in expenses) {
      final key = 'Thg ${expense.date.month}, ${expense.date.year}';
      grouped[key] = (grouped[key] ?? 0) + expense.amount;
    }

    return grouped.entries.map((entry) {
      return MonthlyTrend(
        month: entry.key,
        income: monthlyIncome,
        expense: entry.value,
      );
    }).toList()
      ..sort((a, b) {
        final aParts = a.month.replaceAll('Thg ', '').replaceAll(',', '').trim().split(' ');
        final bParts = b.month.replaceAll('Thg ', '').replaceAll(',', '').trim().split(' ');
        final aMonth = int.tryParse(aParts[0]) ?? 0;
        final bMonth = int.tryParse(bParts[0]) ?? 0;
        return aMonth.compareTo(bMonth);
      });
  }

  List<CategoryTrend> _calculateCategoryBreakdown(List<ExpenseEntity> expenses) {
    final grouped = <String, double>{};
    final counts = <String, int>{};

    for (final expense in expenses) {
      grouped[expense.category] = (grouped[expense.category] ?? 0) + expense.amount;
      counts[expense.category] = (counts[expense.category] ?? 0) + 1;
    }

    final total = grouped.values.fold<double>(0, (a, b) => a + b);

    return grouped.entries.map((entry) {
      return CategoryTrend(
        category: entry.key,
        amount: entry.value,
        percentage: total > 0 ? (entry.value / total * 100) : 0,
        count: counts[entry.key] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  double _predictNextMonth(List<MonthlyTrend> trends) {
    if (trends.isEmpty) return 0;
    final total = trends.fold<double>(0, (acc, t) => acc + t.expense);
    final avg = total / trends.length;
    final variance = trends.fold<double>(0, (acc, t) => acc + (t.expense - avg) * (t.expense - avg));
    final stdDev = variance > 0 ? variance / trends.length : 0;
    return avg + stdDev * 0.3;
  }

  String _generateRecommendation(List<CategoryTrend> breakdown, double totalExpense) {
    if (breakdown.isEmpty) return 'Thêm chi tiêu để nhận đề xuất ngân sách.';

    final topCategory = breakdown.first;
    final suggestedBudget = totalExpense * 1.1;

    if (topCategory.percentage > 40) {
      return 'Danh mục "${topCategory.category}" chiếm ${topCategory.percentage.toStringAsFixed(0)}% tổng chi tiêu. Hãy đặt ngân sách ${suggestedBudget.toStringAsFixed(0)}₫ cho tháng sau.';
    }

    return 'Đề xuất ngân sách tháng sau: ${suggestedBudget.toStringAsFixed(0)}₫. Duy trì thói quen chi tiêu hiện tại!';
  }

  Future<void> predictNextMonth() async {
    if (state.monthlyTrends.isEmpty) {
      await loadAnalytics();
      return;
    }
    final predicted = _predictNextMonth(state.monthlyTrends);
    emit(state.copyWith(predictedNextMonth: predicted));
  }

  List<CategoryTrend> getCategoryTrends() {
    return state.categoryBreakdown;
  }
}
