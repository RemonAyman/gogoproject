// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCGt_zqa8UToESFsa05NZN3ip4v4U64mSc',
    appId: 'REPLACE_WITH_YOUR_WEB_APP_ID', // TODO: User must provide Web App ID
    messagingSenderId: '902909183308',
    projectId: 'brookingapp',
    authDomain: 'brookingapp.firebaseapp.com',
    storageBucket: 'brookingapp.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGt_zqa8UToESFsa05NZN3ip4v4U64mSc',
    appId: '1:902909183308:android:1728f314efe28151d8bbe9',
    messagingSenderId: '902909183308',
    projectId: 'brookingapp',
    storageBucket: 'brookingapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_IOS_API_KEY',
    appId: 'REPLACE_WITH_YOUR_IOS_APP_ID',
    messagingSenderId: '902909183308',
    projectId: 'brookingapp',
    storageBucket: 'brookingapp.firebasestorage.app',
    iosClientId: 'REPLACE_WITH_YOUR_IOS_CLIENT_ID',
    iosBundleId: 'REPLACE_WITH_YOUR_IOS_BUNDLE_ID',
  );
}
