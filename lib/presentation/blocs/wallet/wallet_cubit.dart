import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/wallet_entity.dart';

class WalletState extends Equatable {
  final List<WalletEntity> wallets;
  final bool isLoading;
  final String? error;

  const WalletState({
    this.wallets = const [],
    this.isLoading = false,
    this.error,
  });

  double get totalBalance => wallets.fold<double>(0, (total, w) => total + w.balance);

  WalletState copyWith({
    List<WalletEntity>? wallets,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      wallets: wallets ?? this.wallets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [wallets, isLoading, error];
}

class WalletCubit extends Cubit<WalletState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _walletSub;
  StreamSubscription? _authSub;

  WalletCubit() : super(const WalletState()) {
    _listenToWallets();
  }

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _walletsRef =>
      _firestore.collection('users').doc(_uid).collection('wallets');

  void _listenToWallets() {
    _authSub = _auth.authStateChanges().listen((user) {
      _walletSub?.cancel();
      if (user != null) {
        _walletSub = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wallets')
            .snapshots()
            .listen((snapshot) {
          final wallets = snapshot.docs.map((doc) {
            final data = doc.data();
            return WalletEntity.fromMap(data, doc.id);
          }).toList();
          if (!isClosed) emit(state.copyWith(wallets: wallets, isLoading: false));
        }, onError: (e) {
          if (!isClosed) emit(state.copyWith(error: 'Lỗi tải ví: $e'));
        });
      } else {
        if (!isClosed) emit(const WalletState());
      }
    });
  }

  Future<void> addWallet(WalletEntity wallet) async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      await _walletsRef.add(wallet.toMap());
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi thêm ví: $e'));
    }
  }

  Future<void> updateWallet(String id, Map<String, dynamic> data) async {
    if (_uid == null) return;
    try {
      await _walletsRef.doc(id).update(data);
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi cập nhật ví: $e'));
    }
  }

  Future<void> deleteWallet(String id) async {
    if (_uid == null) return;
    try {
      await _walletsRef.doc(id).delete();
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi xóa ví: $e'));
    }
  }

  Future<void> updateBalance(String walletId, double change) async {
    if (_uid == null) return;
    try {
      final doc = await _walletsRef.doc(walletId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final current = (data?['balance'] as num?)?.toDouble() ?? 0;
        await _walletsRef.doc(walletId).update({'balance': current + change});
      }
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi cập nhật số dư: $e'));
    }
  }

  @override
  Future<void> close() {
    _walletSub?.cancel();
    _authSub?.cancel();
    return super.close();
  }
}
