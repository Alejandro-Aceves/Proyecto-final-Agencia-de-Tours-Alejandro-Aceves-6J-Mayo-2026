import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return null;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBSYwJYwOswrZkBiEP7OVufVYfPiGw_daw',
    appId: '1:526706945942:web:3b145837d725e0bf7537b7',
    messagingSenderId: '526706945942',
    projectId: 'lifetours-452a8',
    authDomain: 'lifetours-452a8.firebaseapp.com',
    storageBucket: 'lifetours-452a8.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSYwJYwOswrZkBiEP7OVufVYfPiGw_daw',
    appId: '1:526706945942:android:3b145837d725e0bf7537b7',
    messagingSenderId: '526706945942',
    projectId: 'lifetours-452a8',
    storageBucket: 'lifetours-452a8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZX8GU9L3QE-zuPEazbPDqYIlqaBVI6Lo',
    appId: '1:526706945942:ios:7e369dd4ad48035b7537b7',
    messagingSenderId: '526706945942',
    projectId: 'lifetours-452a8',
    storageBucket: 'lifetours-452a8.firebasestorage.app',
    iosBundleId: 'com.life.tours',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDZX8GU9L3QE-zuPEazbPDqYIlqaBVI6Lo',
    appId: '1:526706945942:ios:7e369dd4ad48035b7537b7',
    messagingSenderId: '526706945942',
    projectId: 'lifetours-452a8',
    storageBucket: 'lifetours-452a8.firebasestorage.app',
    iosBundleId: 'com.life.tours',
  );
}
