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
    apiKey: 'AIzaSyDwMqMxdm01wOByxt59CIy7OKVOgYp3IBk',
    appId: '1:575512895144:web:6ba63212e0b4fb50c96c9d',
    messagingSenderId: '575512895144',
    projectId: 'track-sl-457a6',
    authDomain: 'track-sl-457a6.firebaseapp.com',
    storageBucket: 'track-sl-457a6.firebasestorage.app',
    measurementId: 'G-4TL7P6XVK2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEB-iKNQoFPIX_oAbbgoYgNRyI7YXm8t0',
    appId: '1:575512895144:android:5c4400ecaa359c2ec96c9d',
    messagingSenderId: '575512895144',
    projectId: 'track-sl-457a6',
    storageBucket: 'track-sl-457a6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAmf3M6KvzfLwjXoymK3jv0FQ4verJci-w',
    appId: '1:575512895144:ios:179ccef90e2ca0a9c96c9d',
    messagingSenderId: '575512895144',
    projectId: 'track-sl-457a6',
    storageBucket: 'track-sl-457a6.firebasestorage.app',
    iosBundleId: 'com.example.driverApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAmf3M6KvzfLwjXoymK3jv0FQ4verJci-w',
    appId: '1:575512895144:ios:179ccef90e2ca0a9c96c9d',
    messagingSenderId: '575512895144',
    projectId: 'track-sl-457a6',
    storageBucket: 'track-sl-457a6.firebasestorage.app',
    iosBundleId: 'com.example.driverApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDwMqMxdm01wOByxt59CIy7OKVOgYp3IBk',
    appId: '1:575512895144:web:64d0d6516b095b48c96c9d',
    messagingSenderId: '575512895144',
    projectId: 'track-sl-457a6',
    authDomain: 'track-sl-457a6.firebaseapp.com',
    storageBucket: 'track-sl-457a6.firebasestorage.app',
    measurementId: 'G-PB0WC61QWC',
  );
}
