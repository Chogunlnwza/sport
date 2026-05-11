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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBKdsGrlaeWZYlnktkcVme4OMGrxrToomM',
    appId: '1:1046913739735:web:0ed29a252bcfed0a227992',
    messagingSenderId: '1046913739735',
    projectId: 'plume-87eda',
    authDomain: 'plume-87eda.firebaseapp.com',
    storageBucket: 'plume-87eda.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKdsGrlaeWZYlnktkcVme4OMGrxrToomM',
    appId: '1:1046913739735:android:346e4ead0b316281227992',
    messagingSenderId: '1046913739735',
    projectId: 'plume-87eda',
    storageBucket: 'plume-87eda.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKdsGrlaeWZYlnktkcVme4OMGrxrToomM',
    appId: '1:1046913739735:ios:346e4ead0b316281227992',
    messagingSenderId: '1046913739735',
    projectId: 'plume-87eda',
    storageBucket: 'plume-87eda.firebasestorage.app',
    iosBundleId: 'com.example.plume',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBKdsGrlaeWZYlnktkcVme4OMGrxrToomM',
    appId: '1:1046913739735:ios:346e4ead0b316281227992',
    messagingSenderId: '1046913739735',
    projectId: 'plume-87eda',
    storageBucket: 'plume-87eda.firebasestorage.app',
    iosBundleId: 'com.example.plume',
  );
}
