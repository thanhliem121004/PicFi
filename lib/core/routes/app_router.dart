import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/expense/add_expense_screen.dart';
import '../../presentation/screens/expense/expense_detail_screen.dart';
import '../../presentation/screens/expense/image_editor_screen.dart';
import '../../presentation/screens/friends/friends_screen.dart';
import '../../presentation/screens/friends/chat_screen.dart';
import '../../presentation/screens/expense/expense_list_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/wallet/wallet_screen.dart';
import '../../presentation/screens/group/group_list_screen.dart';
import '../../presentation/screens/group/group_detail_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../domain/entities/expense_entity.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/main', builder: (context, state) => const MainScreen()),
      GoRoute(path: '/add-expense', builder: (context, state) { final extra = state.extra; return AddExpenseScreen(existingExpense: extra is ExpenseEntity ? extra : null); }),
      GoRoute(path: '/expense-detail/:id', builder: (context, state) { return ExpenseDetailScreen(expenseId: state.pathParameters['id'] ?? ''); }),
      GoRoute(path: '/image-editor', builder: (context, state) { final args = state.extra as Map<String, dynamic>; return ImageEditorScreen(imagePath: args['imagePath'] ?? '', emoji: args['emoji']); }),
      GoRoute(path: '/expenses', builder: (context, state) { final args = state.extra as Map<String, dynamic>? ?? {}; return ExpenseListScreen(initialCategory: args['category']); }),
      GoRoute(path: '/friends', builder: (context, state) => const FriendsScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/profile/:userId', builder: (context, state) => ProfileScreen(userId: state.pathParameters['userId'])),
      GoRoute(path: '/chat/:friendId', builder: (context, state) { final args = state.extra as Map<String, dynamic>? ?? {}; return ChatScreen(friendId: state.pathParameters['friendId'] ?? '', friendName: args['friendName'] ?? ''); }),
      GoRoute(path: '/wallets', builder: (context, state) => const WalletScreen()),
      GoRoute(path: '/groups', builder: (context, state) => const GroupListScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/group-detail/:id', builder: (context, state) { return GroupDetailScreen(groupId: state.pathParameters['id'] ?? ''); }),
    ],
  );
}
