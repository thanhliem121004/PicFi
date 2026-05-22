import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError('DefaultFirebaseOptions are not configured for $defaultTargetPlatform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCu-uCkmcftFfwlyCWkWaN6MRtWYWmY3Ig',
    appId: '1:340213919633:web:YOUR_WEB_APP_ID',
    messagingSenderId: '340213919633',
    projectId: 'fir-dtdm',
    authDomain: 'fir-dtdm.firebaseapp.com',
    storageBucket: 'fir-dtdm.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCu-uCkmcftFfwlyCWkWaN6MRtWYWmY3Ig',
    appId: '1:340213919633:android:8f9e3f3c5bfdf8846eb430',
    messagingSenderId: '340213919633',
    projectId: 'fir-dtdm',
    storageBucket: 'fir-dtdm.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCu-uCkmcftFfwlyCWkWaN6MRtWYWmY3Ig',
    appId: '1:340213919633:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '340213919633',
    projectId: 'fir-dtdm',
    storageBucket: 'fir-dtdm.firebasestorage.app',
    iosBundleId: 'com.picfi.picfi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCu-uCkmcftFfwlyCWkWaN6MRtWYWmY3Ig',
    appId: '1:340213919633:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '340213919633',
    projectId: 'fir-dtdm',
    storageBucket: 'fir-dtdm.firebasestorage.app',
    iosBundleId: 'com.picfi.picfi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCu-uCkmcftFfwlyCWkWaN6MRtWYWmY3Ig',
    appId: '1:340213919633:web:YOUR_WEB_APP_ID',
    messagingSenderId: '340213919633',
    projectId: 'fir-dtdm',
    authDomain: 'fir-dtdm.firebaseapp.com',
    storageBucket: 'fir-dtdm.firebasestorage.app',
  );
}
