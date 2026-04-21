import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/expense/add_expense_screen.dart';
import '../../presentation/screens/expense/expense_detail_screen.dart';
import '../../presentation/screens/friends/friends_screen.dart';
import '../../presentation/screens/friends/chat_screen.dart';
import '../../presentation/screens/expense/expense_list_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/add-expense',
        builder: (context, state) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: '/expense-detail',
        builder: (context, state) {
          final expenseId = state.extra as String? ?? '';
          return ExpenseDetailScreen(expenseId: expenseId);
        },
      ),
      GoRoute(
        path: '/expenses',
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return ChatScreen(
            friendId: args['friendId'] ?? '',
            friendName: args['friendName'] ?? '',
          );
        },
      ),
    ],
  );
}
