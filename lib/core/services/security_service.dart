import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityStatus {
  final bool biometricEnabled;
  final bool pinEnabled;
  final DateTime? lastVerified;

  const SecurityStatus({
    this.biometricEnabled = false,
    this.pinEnabled = false,
    this.lastVerified,
  });

  SecurityStatus copyWith({
    bool? biometricEnabled,
    bool? pinEnabled,
    DateTime? lastVerified,
  }) {
    return SecurityStatus(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      lastVerified: lastVerified ?? this.lastVerified,
    );
  }
}

class SecurityService {
  static const _biometricKey = 'biometric_enabled';
  static const _pinKey = 'pin_enabled';
  static const _pinHashKey = 'pin_hash';
  static const _lastVerifiedKey = 'last_verified';
  static const _encryptionKey = 'encryption_key';

  static final _random = Random();

  Future<bool> enableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, true);
    return true;
  }

  Future<bool> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, false);
    return true;
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricKey) ?? false;
  }

  Future<bool> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = _hashPin(pin);
    await prefs.setString(_pinHashKey, hash);
    await prefs.setBool(_pinKey, true);
    return true;
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_pinHashKey);
    if (storedHash == null) return false;

    final result = storedHash == _hashPin(pin);
    if (result) {
      await prefs.setString(_lastVerifiedKey, DateTime.now().toIso8601String());
    }
    return result;
  }

  Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinKey) ?? false;
  }

  Future<bool> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
    await prefs.setBool(_pinKey, false);
    return true;
  }

  Future<SecurityStatus> getSecurityStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVerifiedStr = prefs.getString(_lastVerifiedKey);
    return SecurityStatus(
      biometricEnabled: prefs.getBool(_biometricKey) ?? false,
      pinEnabled: prefs.getBool(_pinKey) ?? false,
      lastVerified: lastVerifiedStr != null ? DateTime.tryParse(lastVerifiedStr) : null,
    );
  }

  Future<String> encryptSensitiveData(String data) async {
    final key = await _getEncryptionKey();
    final bytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final encrypted = List<int>.generate(bytes.length, (i) {
      return bytes[i] ^ keyBytes[i % keyBytes.length];
    });
    return base64Encode(encrypted);
  }

  Future<String> decryptSensitiveData(String encrypted) async {
    final key = await _getEncryptionKey();
    final bytes = base64Decode(encrypted);
    final keyBytes = utf8.encode(key);
    final decrypted = List<int>.generate(bytes.length, (i) {
      return bytes[i] ^ keyBytes[i % keyBytes.length];
    });
    return utf8.decode(decrypted);
  }

  Future<String> _getEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    var key = prefs.getString(_encryptionKey);
    if (key == null || key.length < 16) {
      key = _generateKey();
      await prefs.setString(_encryptionKey, key);
    }
    return key;
  }

  String _generateKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
    return List.generate(32, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode('picfi_salt_2024_$pin');
    return base64Encode(bytes);
  }
}
