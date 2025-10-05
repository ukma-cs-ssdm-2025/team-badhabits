import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDummyKeyForLocalDevelopment123456',
    appId: '1:123456789:web:abc123',
    messagingSenderId: '123456789',
    projectId: 'badhabits-temp',
    authDomain: 'badhabits-temp.firebaseapp.com',
    storageBucket: 'badhabits-temp.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForLocalDevelopment123456',
    appId: '1:123456789:android:abc123',
    messagingSenderId: '123456789',
    projectId: 'badhabits-temp',
    storageBucket: 'badhabits-temp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForLocalDevelopment123456',
    appId: '1:123456789:ios:abc123',
    messagingSenderId: '123456789',
    projectId: 'badhabits-temp',
    storageBucket: 'badhabits-temp.appspot.com',
    iosBundleId: 'ua.wellity.frontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForLocalDevelopment123456',
    appId: '1:123456789:macos:abc123',
    messagingSenderId: '123456789',
    projectId: 'badhabits-temp',
    storageBucket: 'badhabits-temp.appspot.com',
    iosBundleId: 'ua.wellity.frontend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForLocalDevelopment123456',
    appId: '1:123456789:windows:abc123',
    messagingSenderId: '123456789',
    projectId: 'badhabits-temp',
  );
}
