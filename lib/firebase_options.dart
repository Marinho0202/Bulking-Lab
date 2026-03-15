// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCh2V5rbU-JNTAURy9B55qMfZL3LaDp30M',
    appId: '1:894937243535:web:23565d623ce0618a5c75fa',
    messagingSenderId: '894937243535',
    projectId: 'bulking-app-v0-1',
    authDomain: 'bulking-app-v0-1.firebaseapp.com',
    storageBucket: 'bulking-app-v0-1.firebasestorage.app',
    measurementId: 'G-JQMEGSD78X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqq0D1A7rN4O3ssOxVToG-neHyCTMsYus',
    appId: '1:894937243535:android:c9f57a0513c74e4a5c75fa',
    messagingSenderId: '894937243535',
    projectId: 'bulking-app-v0-1',
    storageBucket: 'bulking-app-v0-1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBuwdNKwKR_Kpu6Se-DdDHEYdBbMbBD5-M',
    appId: '1:894937243535:ios:162061d2d19d88255c75fa',
    messagingSenderId: '894937243535',
    projectId: 'bulking-app-v0-1',
    storageBucket: 'bulking-app-v0-1.firebasestorage.app',
    iosBundleId: 'com.example.bulkingLab',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBuwdNKwKR_Kpu6Se-DdDHEYdBbMbBD5-M',
    appId: '1:894937243535:ios:162061d2d19d88255c75fa',
    messagingSenderId: '894937243535',
    projectId: 'bulking-app-v0-1',
    storageBucket: 'bulking-app-v0-1.firebasestorage.app',
    iosBundleId: 'com.example.bulkingLab',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCh2V5rbU-JNTAURy9B55qMfZL3LaDp30M',
    appId: '1:894937243535:web:1b036cd3ca4a9a505c75fa',
    messagingSenderId: '894937243535',
    projectId: 'bulking-app-v0-1',
    authDomain: 'bulking-app-v0-1.firebaseapp.com',
    storageBucket: 'bulking-app-v0-1.firebasestorage.app',
    measurementId: 'G-M9YBVMSJSJ',
  );
}