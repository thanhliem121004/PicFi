import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:picfi/presentation/blocs/auth/auth_cubit.dart';
import 'package:picfi/presentation/screens/auth/login_screen.dart';
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

Widget createTestApp() {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const Scaffold(body: Text('Register Screen'))),
      GoRoute(path: '/main', builder: (_, __) => const Scaffold(body: Text('Main Screen'))),
    ],
  );

  return BlocProvider<AuthCubit>(
    create: (_) => MockAuthCubit(),
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

void main() {
  setUpAll(() async {
    await setupFirebaseForTests();
  });

  testWidgets('login screen renders', (WidgetTester tester) async {
    if (!isFirebaseSetupSuccessful) return;
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('email and password fields exist', (WidgetTester tester) async {
    if (!isFirebaseSetupSuccessful) return;
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    expect(find.text('PicFi ID hoặc Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
  });

  testWidgets('register button navigates to register screen', (WidgetTester tester) async {
    if (!isFirebaseSetupSuccessful) return;
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Đăng ký'), 100);
    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    expect(find.text('Register Screen'), findsOneWidget);
  });
}
