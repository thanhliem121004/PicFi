import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class BackupState extends Equatable {
  final bool isLoading;
  final String? lastBackupDate;
  final String? error;
  final String? successMessage;

  const BackupState({
    this.isLoading = false,
    this.lastBackupDate,
    this.error,
    this.successMessage,
  });

  BackupState copyWith({
    bool? isLoading,
    String? lastBackupDate,
    String? error,
    String? successMessage,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, lastBackupDate, error, successMessage];
}

class BackupCubit extends Cubit<BackupState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  BackupCubit() : super(const BackupState()) {
    _loadLastBackupDate();
  }

  String? get _uid => _auth.currentUser?.uid;

  Future<void> _loadLastBackupDate() async {
    if (_uid == null) return;
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      final data = doc.data();
      if (data != null && data['lastBackup'] != null) {
        final ts = data['lastBackup'] as Timestamp;
        emit(state.copyWith(lastBackupDate: ts.toDate().toIso8601String()));
      }
    } catch (_) {}
  }

  Future<void> backup(String password) async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    try {
      final data = await _collectAllData();
      final jsonStr = jsonEncode(data);
      final encrypted = _encrypt(jsonStr, password);

      final ref = _storage.ref('backups/$_uid/backup_${DateTime.now().millisecondsSinceEpoch}.enc');
      await ref.putString(encrypted);

      await _firestore.collection('users').doc(_uid).update({
        'lastBackup': FieldValue.serverTimestamp(),
      });

      emit(state.copyWith(
        isLoading: false,
        lastBackupDate: DateTime.now().toIso8601String(),
        successMessage: 'Sao lưu thành công! Dữ liệu đã được mã hóa.',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi sao lưu: $e'));
    }
  }

  Future<void> restore(String password) async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    try {
      final listResult = await _storage.ref('backups/$_uid').list();
      if (listResult.items.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'Không tìm thấy bản sao lưu nào'));
        return;
      }

      final lastBackup = listResult.items
        ..sort((a, b) => b.name.compareTo(a.name));
      final latest = lastBackup.first;

      final byteData = await latest.getData();
      if (byteData == null) {
        emit(state.copyWith(isLoading: false, error: 'Không thể đọc dữ liệu sao lưu'));
        return;
      }

      final encrypted = String.fromCharCodes(byteData);
      final decrypted = _decrypt(encrypted, password);

      if (decrypted == null) {
        emit(state.copyWith(isLoading: false, error: 'Sai mật khẩu hoặc dữ liệu bị hỏng'));
        return;
      }

      final data = jsonDecode(decrypted) as Map<String, dynamic>;
      await _restoreData(data);

      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Khôi phục thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi khôi phục: $e'));
    }
  }

  Future<Map<String, dynamic>> _collectAllData() async {
    if (_uid == null) return {};
    final data = <String, dynamic>{};

    final collections = ['expenses', 'budgets', 'wallets', 'recurring', 'savings_goals'];
    for (final collection in collections) {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection(collection)
          .get();
      data[collection] = snapshot.docs.map((doc) {
        final d = doc.data();
        d['_id'] = doc.id;
        return d;
      }).toList();
    }

    return data;
  }

  Future<void> _restoreData(Map<String, dynamic> data) async {
    if (_uid == null) return;
    for (final entry in data.entries) {
      final collectionName = entry.key;
      final items = entry.value as List<dynamic>;
      for (final item in items) {
        final map = Map<String, dynamic>.from(item as Map);
        final docId = map.remove('_id') as String?;
        if (docId != null) {
          await _firestore
              .collection('users')
              .doc(_uid)
              .collection(collectionName)
              .doc(docId)
              .set(map, SetOptions(merge: true));
        }
      }
    }
  }

  String _encrypt(String plainText, String password) {
    final key = encrypt.Key.fromUtf8(password.padRight(32).substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String? _decrypt(String cipherText, String password) {
    try {
      final key = encrypt.Key.fromUtf8(password.padRight(32).substring(0, 32));
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      return encrypter.decrypt64(cipherText, iv: iv);
    } catch (_) {
      return null;
    }
  }
}
