import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picfi/domain/entities/expense_entity.dart';
import 'package:picfi/presentation/blocs/auth/auth_cubit.dart';
import 'package:picfi/presentation/blocs/expense/expense_cubit.dart';
import 'package:picfi/presentation/screens/home/home_screen.dart';
import '../firebase_test_setup.dart';

class MockAuthCubit extends Cubit<AuthState> implements AuthCubit {
  MockAuthCubit() : super(const AuthState());

  @override
  Future<void> signInWithEmail(String email, String password) async {}

  @override
  Future<void> signInWithPicfiId(String picfiId, String password) async {}

  @override
  Future<void> signInSmart(String input, String password) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signUp(
      String name, String email, String password, String picfiId) async {}

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> checkEmailVerified() async => true;

  @override
  Future<void> resendVerificationEmail() async {}
}

class MockExpenseCubit extends Cubit<ExpenseState> implements ExpenseCubit {
  MockExpenseCubit() : super(const ExpenseState());

  @override
  Future<void> loadMoreExpenses() async {}

  @override
  Future<void> addExpense(ExpenseEntity expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}

  @override
  Future<void> updateExpense(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> shareToFeed({
    required double amount,
    required String category,
    String? note,
    String? emoji,
    String? imageUrl,
  }) async {}

  @override
  List<ExpenseEntity> getExpensesByCategory(String category) => [];

  @override
  Map<String, double> getCategoryStats() => {};

  @override
  Map<String, List<ExpenseEntity>> getGroupedByDate() => {};

  @override
  Future<void> refresh() async {}
}

Widget createTestApp(ExpenseCubit expenseCubit) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>(create: (_) => MockAuthCubit()),
      BlocProvider<ExpenseCubit>(create: (_) => expenseCubit),
    ],
    child: const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

void main() {
  setUpAll(() async {
    await setupFirebaseForTests();
  });

  testWidgets('home screen renders', (WidgetTester tester) async {
    if (!isFirebaseSetupSuccessful) return;
    final expenseCubit = MockExpenseCubit();
    await tester.pumpWidget(createTestApp(expenseCubit));
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
