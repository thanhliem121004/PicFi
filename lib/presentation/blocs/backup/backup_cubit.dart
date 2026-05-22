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

  Future<void> clearAndSeedData() async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    try {
      final collections = ['expenses', 'budgets', 'wallets', 'recurring', 'savings_goals'];
      
      // 1. Delete all existing documents
      for (final coll in collections) {
        final ref = _firestore.collection('users').doc(_uid).collection(coll);
        final snapshot = await ref.get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
      
      // 2. Add Wallets
      final walletRef = _firestore.collection('users').doc(_uid).collection('wallets');
      final wallets = [
        {'id': 'wallet_main', 'name': 'Ví chính 💵', 'balance': 12500000.0, 'color': '0xFF006A65', 'type': 'cash'},
        {'id': 'wallet_visa', 'name': 'Thẻ Visa 💳', 'balance': 5000000.0, 'color': '0xFF3498DB', 'type': 'credit_card'},
        {'id': 'wallet_saving', 'name': 'Quỹ dự phòng 🐷', 'balance': 10000000.0, 'color': '0xFFF1C40F', 'type': 'savings'},
      ];
      for (final w in wallets) {
        await walletRef.doc(w['id'] as String).set({
          'name': w['name'],
          'balance': w['balance'],
          'color': w['color'],
          'type': w['type'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. Add Budgets
      final budgetRef = _firestore.collection('users').doc(_uid).collection('budgets');
      final budgets = [
        {'category': 'food', 'limitAmount': 4000000.0, 'spentAmount': 850000.0},
        {'category': 'coffee', 'limitAmount': 800000.0, 'spentAmount': 180000.0},
        {'category': 'shopping', 'limitAmount': 2500000.0, 'spentAmount': 350000.0},
        {'category': 'transport', 'limitAmount': 1000000.0, 'spentAmount': 140000.0},
      ];
      for (final b in budgets) {
        await budgetRef.doc(b['category'] as String).set({
          'category': b['category'],
          'limitAmount': b['limitAmount'],
          'spentAmount': b['spentAmount'],
          'startDate': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
          'endDate': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        });
      }

      // 4. Add Expenses
      final expenseRef = _firestore.collection('users').doc(_uid).collection('expenses');
      final expenses = [
        {'title': 'Mua sắm Shopee', 'amount': 350000.0, 'category': 'shopping', 'note': 'Mua áo khoác mới', 'walletId': 'wallet_visa', 'daysAgo': 1},
        {'title': 'Cà phê Highlands', 'amount': 45000.0, 'category': 'coffee', 'note': 'Họp nhóm với đồng nghiệp', 'walletId': 'wallet_main', 'daysAgo': 1},
        {'title': 'Cơm tấm sườn', 'amount': 50000.0, 'category': 'food', 'note': 'Ăn trưa', 'walletId': 'wallet_main', 'daysAgo': 2},
        {'title': 'Đổ xăng xe máy', 'amount': 70000.0, 'category': 'transport', 'note': 'Đổ xăng đầy bình', 'walletId': 'wallet_main', 'daysAgo': 2},
        {'title': 'Netflix Premium', 'amount': 260000.0, 'category': 'bills', 'note': 'Gia hạn gói Netflix 4K', 'walletId': 'wallet_visa', 'daysAgo': 3},
        {'title': 'Lẩu Kichi Kichi', 'amount': 480000.0, 'category': 'food', 'note': 'Ăn tối cuối tuần', 'walletId': 'wallet_main', 'daysAgo': 4},
        {'title': 'Mua sách Fahasa', 'amount': 150000.0, 'category': 'education', 'note': 'Sách Đắc Nhân Tâm', 'walletId': 'wallet_main', 'daysAgo': 5},
        {'title': 'Thanh toán tiền điện', 'amount': 680000.0, 'category': 'bills', 'note': 'Tiền điện tháng 5', 'walletId': 'wallet_visa', 'daysAgo': 6},
        {'title': 'Trà sữa Gongcha', 'amount': 55000.0, 'category': 'coffee', 'note': 'Mua trà sữa tự thưởng', 'walletId': 'wallet_main', 'daysAgo': 7},
        {'title': 'Vé xem phim CGV', 'amount': 120000.0, 'category': 'entertainment', 'note': 'Phim Doctor Strange', 'walletId': 'wallet_visa', 'daysAgo': 7},
      ];
      for (final e in expenses) {
        await expenseRef.add({
          'title': e['title'],
          'amount': e['amount'],
          'category': e['category'],
          'note': e['note'],
          'walletId': e['walletId'],
          'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: e['daysAgo'] as int))),
        });
      }

      // 5. Add Savings Goals
      final goalRef = _firestore.collection('users').doc(_uid).collection('savings_goals');
      final goals = [
        {'name': 'Mua iPhone 16 Pro 📱', 'targetAmount': 30000000.0, 'currentAmount': 8000000.0, 'color': '0xFFE74C3C'},
        {'name': 'Du lịch Nhật Bản 🌸', 'targetAmount': 50000000.0, 'currentAmount': 15000000.0, 'color': '0xFF9B59B6'},
      ];
      for (final g in goals) {
        await goalRef.add({
          'name': g['name'],
          'targetAmount': g['targetAmount'],
          'currentAmount': g['currentAmount'],
          'color': g['color'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 6. Add Recurring Expenses
      final recurringRef = _firestore.collection('users').doc(_uid).collection('recurring');
      final recurrings = [
        {'title': 'Tiền mạng Internet 🌐', 'amount': 250000.0, 'category': 'bills', 'interval': 'monthly'},
        {'title': 'Spotify Family 🎵', 'amount': 99000.0, 'category': 'entertainment', 'interval': 'monthly'},
      ];
      for (final r in recurrings) {
        await recurringRef.add({
          'title': r['title'],
          'amount': r['amount'],
          'category': r['category'],
          'interval': r['interval'],
          'nextDueDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 10))),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Đã dọn sạch Firestore và khởi tạo lại dữ liệu mẫu thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi dọn dẹp dữ liệu: $e'));
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
