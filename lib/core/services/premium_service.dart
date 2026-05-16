import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/premium_entity.dart';

class PremiumService {
  static const _premiumKey = 'is_premium';
  static const _planKey = 'premium_plan';
  static const _expiryKey = 'premium_expiry';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _statusController = StreamController<PremiumStatus>.broadcast();

  String? get _uid => _auth.currentUser?.uid;

  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }

  List<PremiumFeatures> getPremiumFeatures() {
    return PremiumFeatures.values;
  }

  Future<bool> purchaseSubscription(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    PremiumPlan plan;
    switch (planId) {
      case 'monthly':
        plan = PremiumPlan.monthly;
        break;
      case 'yearly':
        plan = PremiumPlan.yearly;
        break;
      case 'lifetime':
        plan = PremiumPlan.lifetime;
        break;
      default:
        return false;
    }

    await prefs.setBool(_premiumKey, true);
    await prefs.setString(_planKey, plan.name);

    DateTime expiry;
    switch (plan) {
      case PremiumPlan.monthly:
        expiry = DateTime.now().add(const Duration(days: 30));
        break;
      case PremiumPlan.yearly:
        expiry = DateTime.now().add(const Duration(days: 365));
        break;
      case PremiumPlan.lifetime:
        expiry = DateTime(2100, 1, 1);
        break;
    }

    await prefs.setString(_expiryKey, expiry.toIso8601String());

    if (_uid != null) {
      await _firestore.collection('users').doc(_uid).collection('premium').doc('subscription').set({
        'isPremium': true,
        'plan': plan.name,
        'expiryDate': Timestamp.fromDate(expiry),
        'purchasedAt': FieldValue.serverTimestamp(),
      });
    }

    _statusController.add(PremiumStatus.active);
    return true;
  }

  Future<bool> restorePurchase() async {
    if (_uid == null) return false;
    try {
      final doc = await _firestore.collection('users').doc(_uid).collection('premium').doc('subscription').get();
      if (doc.exists) {
        final data = doc.data()!;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_premiumKey, data['isPremium'] ?? false);
        await prefs.setString(_planKey, data['plan'] ?? 'monthly');
        final expiry = (data['expiryDate'] as Timestamp?)?.toDate();
        if (expiry != null) {
          await prefs.setString(_expiryKey, expiry.toIso8601String());
        }
        final status = data['isPremium'] == true ? PremiumStatus.active : PremiumStatus.inactive;
        _statusController.add(status);
        return data['isPremium'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Stream<PremiumStatus> getSubscriptionStatus() {
    _loadInitialStatus();
    return _statusController.stream;
  }

  Future<void> _loadInitialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumKey) ?? false;
    if (isPremium) {
      final expiryStr = prefs.getString(_expiryKey);
      if (expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);
        if (expiry.isBefore(DateTime.now())) {
          await prefs.setBool(_premiumKey, false);
          _statusController.add(PremiumStatus.expired);
          return;
        }
      }
      _statusController.add(PremiumStatus.active);
    } else {
      _statusController.add(PremiumStatus.inactive);
    }
  }

  void dispose() {
    _statusController.close();
  }
}
