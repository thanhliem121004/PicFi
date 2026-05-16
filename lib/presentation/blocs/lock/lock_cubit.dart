import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LockState extends Equatable {
  final bool isLocked;
  final bool isEnabled;
  final bool useBiometric;
  final bool isLoading;

  const LockState({
    this.isLocked = true,
    this.isEnabled = false,
    this.useBiometric = false,
    this.isLoading = true,
  });

  LockState copyWith({
    bool? isLocked,
    bool? isEnabled,
    bool? useBiometric,
    bool? isLoading,
  }) {
    return LockState(
      isLocked: isLocked ?? this.isLocked,
      isEnabled: isEnabled ?? this.isEnabled,
      useBiometric: useBiometric ?? this.useBiometric,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [isLocked, isEnabled, useBiometric, isLoading];
}

class LockCubit extends Cubit<LockState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _auth = LocalAuthentication();

  LockCubit() : super(const LockState()) {
    _init();
  }

  Future<void> _init() async {
    final pin = await _storage.read(key: 'app_pin');
    final bioStr = await _storage.read(key: 'use_biometric');
    emit(state.copyWith(
      isEnabled: pin != null,
      useBiometric: bioStr == 'true',
      isLoading: false,
    ));
  }

  Future<bool> setPin(String pin) async {
    if (pin.length < 4) return false;
    await _storage.write(key: 'app_pin', value: pin);
    emit(state.copyWith(isEnabled: true, isLocked: true));
    return true;
  }

  Future<void> removePin() async {
    await _storage.delete(key: 'app_pin');
    await _storage.delete(key: 'use_biometric');
    emit(state.copyWith(isEnabled: false, useBiometric: false, isLocked: false));
  }

  Future<void> toggleBiometric(bool value) async {
    await _storage.write(key: 'use_biometric', value: value.toString());
    emit(state.copyWith(useBiometric: value));
  }

  Future<bool> authenticate() async {
    if (!state.isEnabled) {
      emit(state.copyWith(isLocked: false));
      return true;
    }

    if (state.useBiometric) {
      try {
        final canCheck = await _auth.canCheckBiometrics;
        if (canCheck) {
          final result = await _auth.authenticate(
            localizedReason: 'Mở khóa PicFi',
            options: const AuthenticationOptions(useErrorDialogs: true, stickyAuth: true),
          );
          if (result) {
            emit(state.copyWith(isLocked: false));
            return true;
          }
        }
      } catch (_) {}
    }
    return false;
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: 'app_pin');
    if (stored == pin) {
      emit(state.copyWith(isLocked: false));
      return true;
    }
    return false;
  }

  void lock() => emit(state.copyWith(isLocked: true));
}
