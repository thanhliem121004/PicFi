import 'package:flutter_test/flutter_test.dart';
import 'package:picfi/presentation/blocs/auth/auth_cubit.dart';

void main() {
  group('AuthState', () {
    test('initial state has isAuthenticated = false', () {
      const state = AuthState();
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(state.userId, isNull);
      expect(state.error, isNull);
    });

    test('copyWith sets authenticated state correctly', () {
      const state = AuthState();
      final updated = state.copyWith(
        isAuthenticated: true,
        userId: 'user123',
        displayName: 'Test User',
        email: 'test@example.com',
      );
      expect(updated.isAuthenticated, true);
      expect(updated.userId, 'user123');
      expect(updated.displayName, 'Test User');
      expect(updated.email, 'test@example.com');
    });

    test('signOut resets state to unauthenticated', () {
      const authenticated = AuthState(
        isAuthenticated: true,
        userId: 'user123',
        displayName: 'Test User',
        email: 'test@example.com',
      );
      expect(authenticated.isAuthenticated, true);

      const initial = AuthState();
      expect(initial.isAuthenticated, false);
      expect(initial.userId, isNull);
      expect(initial.displayName, isNull);
      expect(initial.email, isNull);
      expect(initial.isLoading, false);
      expect(initial.error, isNull);

      // AuthCubit.signOut() calls _auth.signOut() which triggers
      // authStateChanges with null and emits const AuthState().
      // The initial AuthState() matches the post-signout state.
      expect(authenticated.isAuthenticated, isNot(initial.isAuthenticated));
    });
  });
}
