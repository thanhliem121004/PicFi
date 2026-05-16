import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/offline_service.dart';

class ConnectivityState extends Equatable {
  final bool isOnline;

  const ConnectivityState({this.isOnline = true});

  @override
  List<Object?> get props => [isOnline];
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final OfflineService _offlineService = OfflineService.instance;
  StreamSubscription? _sub;

  ConnectivityCubit() : super(const ConnectivityState()) {
    _sub = _offlineService.statusStream.listen((status) {
      final isOnline = status == ConnectivityStatus.online;
      final wasOffline = !state.isOnline;
      emit(ConnectivityState(isOnline: isOnline));

      if (isOnline && wasOffline) {
        _flushPendingActions();
      }
    });
  }

  Future<void> _flushPendingActions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _offlineService.flushQueue((action) async {
      final type = action['type'] as String?;
      switch (type) {
        case 'addExpense':
          final data = action['data'] as Map<String, dynamic>?;
          if (data != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('expenses')
                .add(data);
          }
          break;
        case 'deleteExpense':
          final expenseId = action['expenseId'] as String?;
          if (expenseId != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('expenses')
                .doc(expenseId)
                .delete();
          }
          break;
        default:
          break;
      }
    });
  }

  Future<void> enqueueAction(Map<String, dynamic> action) async {
    await _offlineService.enqueueAction(action);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
