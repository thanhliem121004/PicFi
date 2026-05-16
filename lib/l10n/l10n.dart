import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class L10n {
  L10n._();

  static const _defaultLocale = 'vi';

  static const Map<String, Map<String, String>> _allStrings = {
    'vi': {
      'appName': 'PicFi',
      'appTagline': 'Quản lý tài chính qua hình ảnh để lưu lại những khoảnh khắc chi tiêu của bạn',
      'splashSubtitle': 'Nhật ký tài chính bằng hình ảnh',
      'totalBalance': 'Tổng số dư',
      'income': 'THU NHẬP',
      'expense': 'CHI TIÊU',
      'home': 'Trang chủ',
      'login': 'Đăng nhập',
      'register': 'Đăng ký',
      'logout': 'Đăng xuất',
      'email': 'Email',
      'password': 'Mật khẩu',
      'confirmPassword': 'Xác nhận mật khẩu',
      'forgotPassword': 'Quên mật khẩu?',
      'noAccount': 'Chưa có tài khoản?',
      'hasAccount': 'Đã có tài khoản?',
      'save': 'Lưu',
      'cancel': 'Hủy',
      'delete': 'Xóa',
      'edit': 'Sửa',
      'loading': 'Đang tải...',
      'error': 'Lỗi',
      'success': 'Thành công',
      'today': 'Hôm nay',
      'yesterday': 'Hôm qua',
      'budget': 'Ngân sách',
      'profile': 'Hồ sơ',
      'offlineMode': 'Bạn đang offline',
      'currency': 'đ',
      'daysAgo': 'ngày trước',
    },
    'en': {
      'appName': 'PicFi',
      'appTagline': 'Manage your expenses with photos to capture every spending moment',
      'splashSubtitle': 'Visual finance diary',
      'totalBalance': 'Total Balance',
      'income': 'INCOME',
      'expense': 'EXPENSE',
      'home': 'Home',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'noAccount': "Don't have an account?",
      'hasAccount': 'Already have an account?',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'budget': 'Budget',
      'profile': 'Profile',
      'offlineMode': 'You are offline',
      'currency': '₫',
      'daysAgo': 'days ago',
    },
  };

  static String _currentLocale = _defaultLocale;

  static String get currentLocale => _currentLocale;

  static void setLocale(String locale) {
    if (_allStrings.containsKey(locale)) {
      _currentLocale = locale;
    }
  }

  static String tr(String key) {
    return _allStrings[_currentLocale]?[key] ?? _allStrings[_defaultLocale]?[key] ?? key;
  }

  static Locale get locale => Locale(_currentLocale);

  static const List<Locale> supportedLocales = [
    Locale('vi'),
    Locale('en'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
