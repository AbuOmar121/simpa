// B:\flutter projects\testing_1\lib\firebase\firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAxQkoDFsN-GjQp5o9r3cR7e03mBZnpKkA',
    appId: '1:861521744484:android:28f91394da1d9aac680571',
    messagingSenderId: '861521744484',
    projectId: 'simpa-f74d3',
    storageBucket: 'simpa-f74d3.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey:
        'AIzaSyAxQkoDFsN-GjQp5o9r3cR7e03mBZnpKkA',
    appId: '1:861521744484:web:your-web-app-id',
    messagingSenderId: '861521744484',
    projectId: 'simpa-f74d3',
    authDomain: 'simpa-f74d3.firebaseapp.com',
    storageBucket: 'simpa-f74d3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSy...',
    appId: '1:861521744484:ios:your-ios-app-id',
    messagingSenderId: '861521744484',
    projectId: 'simpa-f74d3',
    storageBucket: 'simpa-f74d3.appspot.com',
    iosBundleId: 'com.example.simpa',
  );
}
