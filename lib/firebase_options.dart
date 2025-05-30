// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAdTy_kbPUgf0Ju4mLce74AmooIbI4vVmw',
    appId: '1:543893381100:web:6cc23ba6cb2ecdbef66ac9',
    messagingSenderId: '543893381100',
    projectId: 'mangasunday-13de5',
    authDomain: 'mangasunday-13de5.firebaseapp.com',
    storageBucket: 'mangasunday-13de5.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_MTvJzjqLBmJ65lvfj04CDBMiGtoIFH0',
    appId: '1:543893381100:android:3da46774de83b533f66ac9',
    messagingSenderId: '543893381100',
    projectId: 'mangasunday-13de5',
    storageBucket: 'mangasunday-13de5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCuA0k3Y8TlOO2HSd8A8Th730g7wlczvv8',
    appId: '1:543893381100:ios:ed913f97774b740ff66ac9',
    messagingSenderId: '543893381100',
    projectId: 'mangasunday-13de5',
    storageBucket: 'mangasunday-13de5.firebasestorage.app',
    iosBundleId: 'com.example.manganuhu',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCuA0k3Y8TlOO2HSd8A8Th730g7wlczvv8',
    appId: '1:543893381100:ios:ed913f97774b740ff66ac9',
    messagingSenderId: '543893381100',
    projectId: 'mangasunday-13de5',
    storageBucket: 'mangasunday-13de5.firebasestorage.app',
    iosBundleId: 'com.example.manganuhu',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAdTy_kbPUgf0Ju4mLce74AmooIbI4vVmw',
    appId: '1:543893381100:web:99fa977e6d1dafcaf66ac9',
    messagingSenderId: '543893381100',
    projectId: 'mangasunday-13de5',
    authDomain: 'mangasunday-13de5.firebaseapp.com',
    storageBucket: 'mangasunday-13de5.firebasestorage.app',
  );
}
