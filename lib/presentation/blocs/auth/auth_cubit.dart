import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════ STATE ═══════════
class AuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final String? userId;
  final String? picfiId;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userId,
    this.picfiId,
    this.displayName,
    this.email,
    this.photoUrl,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? userId,
    String? picfiId,
    String? displayName,
    String? email,
    String? photoUrl,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      picfiId: picfiId ?? this.picfiId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isAuthenticated, isLoading, userId, picfiId, displayName, email, photoUrl, error];
}

// ═══════════ CUBIT ═══════════
class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(const AuthState()) {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserProfile(user);
      } else {
        emit(const AuthState());
      }
    });
  }

  /// Load user profile from Firestore, create if missing
  Future<void> _loadUserProfile(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        emit(state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userId: user.uid,
          picfiId: data['picfiId'] ?? '',
          displayName: data['displayName'] ?? user.displayName ?? 'Người dùng PicFi',
          email: data['email'] ?? user.email,
          photoUrl: data['photoUrl'] ?? user.photoURL,
        ));
      } else {
        // Fallback: user doc doesn't exist yet (legacy signup)
        emit(state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userId: user.uid,
          displayName: user.displayName ?? 'Người dùng PicFi',
          email: user.email,
          photoUrl: user.photoURL,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        userId: user.uid,
        displayName: user.displayName ?? 'Người dùng PicFi',
        email: user.email,
        photoUrl: user.photoURL,
      ));
    }
  }

  /// Đăng nhập bằng email + password
  Future<void> signInWithEmail(String email, String password) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'Tài khoản không tồn tại';
          break;
        case 'wrong-password':
          msg = 'Mật khẩu không đúng';
          break;
        case 'invalid-email':
          msg = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          msg = 'Tài khoản đã bị khóa';
          break;
        case 'invalid-credential':
          msg = 'Thông tin đăng nhập không hợp lệ';
          break;
        default:
          msg = 'Lỗi đăng nhập: ${e.message}';
      }
      emit(state.copyWith(isLoading: false, error: msg));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi: $e'));
    }
  }

  /// Đăng nhập bằng PicFi ID + password
  /// Tìm email từ Firestore theo picfiId, rồi đăng nhập bằng email
  Future<void> signInWithPicfiId(String picfiId, String password) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final trimmedId = picfiId.trim();

      // Tìm user trong Firestore theo picfiId
      final query = await _firestore
          .collection('users')
          .where('picfiId', isEqualTo: trimmedId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'Không tìm thấy tài khoản với ID "$trimmedId"'));
        return;
      }

      final email = query.docs.first.data()['email'] as String?;
      if (email == null || email.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'Tài khoản không có email'));
        return;
      }

      // Đăng nhập bằng email tìm được
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'wrong-password':
          msg = 'Mật khẩu không đúng';
          break;
        case 'invalid-credential':
          msg = 'Thông tin đăng nhập không hợp lệ';
          break;
        default:
          msg = 'Lỗi đăng nhập: ${e.message}';
      }
      emit(state.copyWith(isLoading: false, error: msg));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi: $e'));
    }
  }

  /// Đăng nhập linh hoạt: nếu input chứa "@" → email, ngược lại → PicFi ID
  Future<void> signInSmart(String input, String password) async {
    if (input.contains('@')) {
      await signInWithEmail(input, password);
    } else {
      await signInWithPicfiId(input, password);
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      emit(state.copyWith(isLoading: false, error: 'Google Sign-In chưa được cấu hình SHA-1'));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Đăng ký với PicFi ID do người dùng tự chọn
  Future<void> signUp(String name, String email, String password, String picfiId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final trimmedId = picfiId.trim();

      // Validate PicFi ID format
      if (trimmedId.length < 3) {
        emit(state.copyWith(isLoading: false, error: 'PicFi ID phải có ít nhất 3 ký tự'));
        return;
      }
      if (trimmedId.length > 20) {
        emit(state.copyWith(isLoading: false, error: 'PicFi ID không được quá 20 ký tự'));
        return;
      }
      if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(trimmedId)) {
        emit(state.copyWith(isLoading: false, error: 'PicFi ID chỉ được dùng chữ, số, dấu chấm và gạch dưới'));
        return;
      }

      // Check uniqueness
      final existing = await _firestore
          .collection('users')
          .where('picfiId', isEqualTo: trimmedId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        emit(state.copyWith(isLoading: false, error: 'PicFi ID "$trimmedId" đã được sử dụng, vui lòng chọn ID khác'));
        return;
      }

      // Create Firebase Auth account
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      await cred.user?.reload();

      // Create Firestore user profile with chosen PicFi ID
      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'picfiId': trimmedId,
          'displayName': name,
          'email': email,
          'photoUrl': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      // authStateChanges listener will pick up the new user
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Email này đã được sử dụng';
          break;
        case 'weak-password':
          msg = 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
          break;
        case 'invalid-email':
          msg = 'Email không hợp lệ';
          break;
        default:
          msg = 'Lỗi đăng ký: ${e.message}';
      }
      emit(state.copyWith(isLoading: false, error: msg));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi: $e'));
    }
  }

  /// Cập nhật profile
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (state.userId == null) return;
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      await _firestore.collection('users').doc(state.userId).update(updates);

      if (displayName != null) {
        await _auth.currentUser?.updateDisplayName(displayName);
      }
      emit(state.copyWith(
        displayName: displayName ?? state.displayName,
        photoUrl: photoUrl ?? state.photoUrl,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi cập nhật: $e'));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
