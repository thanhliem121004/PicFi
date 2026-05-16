import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/premium_entity.dart';
import '../../../core/services/premium_service.dart';

class PremiumState extends Equatable {
  final bool isPremium;
  final PremiumPlan? plan;
  final List<PremiumFeatures> features;
  final DateTime? expiryDate;
  final bool isLoading;
  final String? error;

  const PremiumState({
    this.isPremium = false,
    this.plan,
    this.features = const [],
    this.expiryDate,
    this.isLoading = false,
    this.error,
  });

  PremiumState copyWith({
    bool? isPremium,
    PremiumPlan? plan,
    List<PremiumFeatures>? features,
    DateTime? expiryDate,
    bool? isLoading,
    String? error,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      plan: plan ?? this.plan,
      features: features ?? this.features,
      expiryDate: expiryDate ?? this.expiryDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isPremium, plan, features, expiryDate, isLoading, error];
}

class PremiumCubit extends Cubit<PremiumState> {
  final PremiumService _service = PremiumService();
  StreamSubscription? _statusSub;

  PremiumCubit() : super(const PremiumState()) {
    _listenToStatus();
  }

  void _listenToStatus() {
    _statusSub = _service.getSubscriptionStatus().listen((status) {
      switch (status) {
        case PremiumStatus.active:
          emit(state.copyWith(isPremium: true));
          break;
        case PremiumStatus.inactive:
        case PremiumStatus.expired:
        case PremiumStatus.cancelled:
          emit(state.copyWith(isPremium: false));
          break;
      }
    });
  }

  Future<void> purchase(String planId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final success = await _service.purchaseSubscription(planId);
      if (success) {
        final plan = _parsePlan(planId);
        emit(state.copyWith(
          isPremium: true,
          plan: plan,
          features: _service.getPremiumFeatures(),
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Không thể hoàn tất giao dịch'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi: $e'));
    }
  }

  Future<void> restore() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final restored = await _service.restorePurchase();
      if (restored) {
        emit(state.copyWith(
          isPremium: true,
          features: _service.getPremiumFeatures(),
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Không tìm thấy giao dịch trước đó'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi: $e'));
    }
  }

  Future<void> checkStatus() async {
    final isPremium = await _service.isPremium();
    emit(state.copyWith(
      isPremium: isPremium,
      features: isPremium ? _service.getPremiumFeatures() : [],
    ));
  }

  PremiumPlan _parsePlan(String planId) {
    switch (planId) {
      case 'monthly':
        return PremiumPlan.monthly;
      case 'yearly':
        return PremiumPlan.yearly;
      case 'lifetime':
        return PremiumPlan.lifetime;
      default:
        return PremiumPlan.monthly;
    }
  }

  @override
  Future<void> close() {
    _statusSub?.cancel();
    _service.dispose();
    return super.close();
  }
}
