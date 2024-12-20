// File generated by FlutterFire CLI.
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
    apiKey: 'AIzaSyA9z1iKmsUAYV-AbMYdrlra94g74nalpvA',
    appId: '1:1068413805267:web:6ec0ff0be4e34a19eaea26',
    messagingSenderId: '1068413805267',
    projectId: 'tfrb-2c136',
    authDomain: 'tfrb-2c136.firebaseapp.com',
    storageBucket: 'tfrb-2c136.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDh749uSZepwMPQEQfQk9gmIdha-dy_Qkg',
    appId: '1:1068413805267:android:4552485404d593e2eaea26',
    messagingSenderId: '1068413805267',
    projectId: 'tfrb-2c136',
    storageBucket: 'tfrb-2c136.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzhvnDnlv1dA2bFQj1R9WU70nqPAyXXAA',
    appId: '1:1068413805267:ios:c302f7989223fc8aeaea26',
    messagingSenderId: '1068413805267',
    projectId: 'tfrb-2c136',
    storageBucket: 'tfrb-2c136.appspot.com',
    iosBundleId: 'com.tfrb.utem.tfrbUserside',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCzhvnDnlv1dA2bFQj1R9WU70nqPAyXXAA',
    appId: '1:1068413805267:ios:cfc5a9944dc331abeaea26',
    messagingSenderId: '1068413805267',
    projectId: 'tfrb-2c136',
    storageBucket: 'tfrb-2c136.appspot.com',
    iosBundleId: 'com.tfrb.utem.tfrbUserside.RunnerTests',
  );
}
