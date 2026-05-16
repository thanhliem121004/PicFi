import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'premium_service.dart';

class SmartNotificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PremiumService _premiumService = PremiumService();

  Timer? _budgetTimer;
  Timer? _streakTimer;

  String? get _uid => _auth.currentUser?.uid;

  Future<bool> _canSend() async {
    final isPremium = await _premiumService.isPremium();
    if (!isPremium) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('smart_notifications_enabled') ?? true;
  }

  Future<void> scheduleBudgetReminder() async {
    if (!await _canSend()) return;

    _budgetTimer?.cancel();
    _budgetTimer = Timer.periodic(const Duration(hours: 168), (_) async {
      if (_uid == null) return;
      try {
        final now = DateTime.now();
        final snap = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('budgets')
            .where('month', isEqualTo: now.month)
            .where('year', isEqualTo: now.year)
            .get();

        for (final doc in snap.docs) {
          final data = doc.data();
          final limit = (data['monthlyLimit'] as num?)?.toDouble() ?? 0;
          final spent = (data['currentSpent'] as num?)?.toDouble() ?? 0;
          if (limit > 0 && spent / limit > 0.8) {
            await _sendNotification(
              'Cảnh báo ngân sách',
              'Bạn đã sử dụng ${(spent / limit * 100).toStringAsFixed(0)}% ngân sách ${data['category']}.',
            );
          }
        }
      } catch (_) {}
    });
  }

  Future<void> scheduleStreakReminder() async {
    if (!await _canSend()) return;

    _streakTimer?.cancel();
    _streakTimer = Timer.periodic(const Duration(days: 1), (_) async {
      if (_uid == null) return;
      try {
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);

        final expenses = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('expenses')
            .where('date', isGreaterThanOrEqualTo: startOfDay)
            .where('date', isLessThan: startOfDay.add(const Duration(days: 1)))
            .limit(1)
            .get();

        if (expenses.docs.isEmpty) {
          await _sendNotification(
            'Giữ streak của bạn! 🔥',
            'Hãy ghi chép chi tiêu hôm nay để giữ streak nhé!',
          );
        }
      } catch (_) {}
    });
  }

  Future<void> sendSmartInsight() async {
    if (!await _canSend()) return;
    if (_uid == null) return;

    try {
      final snap = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .limit(20)
          .get();

      final total = snap.docs.fold<double>(0, (sum, doc) {
        final data = doc.data();
        return sum + ((data['amount'] as num?)?.toDouble() ?? 0);
      });

      await _sendNotification(
        'Thông tin chi tiêu hàng tuần 📊',
        'Tuần này bạn đã chi $total₫ cho ${snap.docs.length} giao dịch.',
      );
    } catch (_) {}
  }

  Future<void> scheduleBillReminder() async {
    if (!await _canSend()) return;

    Timer.periodic(const Duration(days: 1), (_) async {
      if (_uid == null) return;
      try {
        final now = DateTime.now();
        if (now.day >= 25 || now.day <= 5) {
          await _sendNotification(
            'Nhắc thanh toán hóa đơn 📋',
            'Sắp đến hạn thanh toán hóa đơn cuối tháng. Hãy kiểm tra và thanh toán đúng hạn!',
          );
        }
      } catch (_) {}
    });
  }

  Future<void> _sendNotification(String title, String body) async {
    try {
      await _firestore.collection('users').doc(_uid).collection('notifications').add({
        'title': title,
        'body': body,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    _budgetTimer?.cancel();
    _streakTimer?.cancel();
  }
}
