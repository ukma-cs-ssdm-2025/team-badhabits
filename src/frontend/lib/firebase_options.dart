import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAMVOp-EfmTxIl32w6qMIifPo5KdFBWEw',
    appId: '1:1029575967903:android:aa22f694000ffbd58f0eaa',
    messagingSenderId: '1029575967903',
    projectId: 'wellity-ce2a3',
    storageBucket: 'wellity-ce2a3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyABMQFPbs3bjHQ5rI17S3LQ9NCiU5jinDw',
    appId: '1:1029575967903:ios:a40253e7a5fadfd98f0eaa',
    messagingSenderId: '1029575967903',
    projectId: 'wellity-ce2a3',
    storageBucket: 'wellity-ce2a3.firebasestorage.app',
    iosBundleId: 'ua.wellity.frontend',
  );

}