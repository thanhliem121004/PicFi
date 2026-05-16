import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  LockCubit() : super(const LockState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('app_pin');
    final bioStr = prefs.getBool('use_biometric') ?? false;
    emit(state.copyWith(
      isEnabled: pin != null && pin.isNotEmpty,
      useBiometric: bioStr,
      isLoading: false,
    ));
  }

  Future<bool> setPin(String pin) async {
    if (pin.length < 4) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_pin', pin);
    emit(state.copyWith(isEnabled: true, isLocked: true));
    return true;
  }

  Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_pin');
    await prefs.remove('use_biometric');
    emit(state.copyWith(isEnabled: false, useBiometric: false, isLocked: false));
  }

  Future<void> toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_biometric', value);
    emit(state.copyWith(useBiometric: value));
  }

  Future<bool> authenticate() async {
    if (!state.isEnabled) {
      emit(state.copyWith(isLocked: false));
      return true;
    }
    return false;
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('app_pin');
    if (stored == pin) {
      emit(state.copyWith(isLocked: false));
      return true;
    }
    return false;
  }

  void lock() => emit(state.copyWith(isLocked: true));
}
