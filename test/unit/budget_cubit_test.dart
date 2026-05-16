import 'package:flutter_test/flutter_test.dart';
import 'package:picfi/presentation/blocs/budget/budget_cubit.dart';
import 'package:picfi/domain/entities/budget_entity.dart';

void main() {
  group('BudgetState', () {
    test('initial state has empty budgets list', () {
      const state = BudgetState();
      expect(state.budgets, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('totalSpent returns 0 for empty budgets', () {
      const state = BudgetState();
      expect(state.totalSpent, 0);
    });

    test('totalLimit returns 0 for empty budgets', () {
      const state = BudgetState();
      expect(state.totalLimit, 0);
    });
  });

  group('BudgetEntity limit checks', () {
    final now = DateTime.now();
    final entity = BudgetEntity(
      id: '1',
      userId: 'user1',
      category: 'catFood',
      monthlyLimit: 1000,
      month: now.month,
      year: now.year,
      currentSpent: 500,
      updatedAt: now,
    );

    test('usedPercent returns correct percentage', () {
      expect(entity.usedPercent, 50);
    });

    test('remainingAmount returns correct remaining', () {
      expect(entity.remainingAmount, 500);
    });

    test('isOverBudget returns false when under limit', () {
      expect(entity.isOverBudget, false);
    });

    test('isOverBudget returns true when over limit', () {
      final over = entity.copyWith(currentSpent: 1500);
      expect(over.isOverBudget, true);
    });

    test('isNearLimit returns true when at 80% or more', () {
      final near = entity.copyWith(currentSpent: 800);
      expect(near.isNearLimit, true);
    });

    test('isNearLimit returns false when under 80%', () {
      expect(entity.isNearLimit, false);
    });

    test('isNearLimit returns false when over budget', () {
      final over = entity.copyWith(currentSpent: 1100);
      expect(over.isNearLimit, false);
      expect(over.isOverBudget, true);
    });

    test('usedPercent clamps at 999', () {
      final extreme = entity.copyWith(currentSpent: 50000);
      expect(extreme.usedPercent, 999);
    });

    test('usedPercent returns 0 when monthlyLimit is 0', () {
      final zero = entity.copyWith(monthlyLimit: 0);
      expect(zero.usedPercent, 0);
    });
  });
}
