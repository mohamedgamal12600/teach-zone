// firebase_options.dart
// Generated FirebaseOptions for teach-zone-adec7
// Compatible with firebase_core ^4.15.0, firebase_auth ^5.4.0, cloud_firestore ^5.4.4

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web — '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS — '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows — '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux — '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Firebase options for Android.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJFqI2g5w4LS_vFaoK2MGTE4CvahI9wN8',
    appId: '1:395561619175:android:effa456c708e41df7d5c42',
    messagingSenderId: '395561619175',
    projectId: 'teach-zone-adec7',
    storageBucket: 'teach-zone-adec7.firebasestorage.app',
  );

  /// Firebase options for iOS.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsHc1benErrNk9Qk7S2Cq_JEhrBN7jJV8',
    appId: '1:395561619175:ios:238908831f26fc407d5c42',
    messagingSenderId: '395561619175',
    projectId: 'teach-zone-adec7',
    storageBucket: 'teach-zone-adec7.firebasestorage.app',
    iosClientId:
        '395561619175-8ajk8rbglvc8727a87ueiuebcf1pmrvq.apps.googleusercontent.com',
    iosBundleId: 'com.example.teachzone',
  );
}
