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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDkPmJVJzfmF7hPrb7wAi5BSL38430Wn04',
    authDomain: 'smart-study-buddy-16111.firebaseapp.com',
    projectId: 'smart-study-buddy-16111',
    storageBucket: 'smart-study-buddy-16111.firebasestorage.app',
    messagingSenderId: '318367609801',
    appId: '1:318367609801:web:c4498bf48c98c01bbcee18',
    measurementId: 'G-8S6D10GN5J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDkPmJVJzfmF7hPrb7wAi5BSL38430Wn04',
    authDomain: 'smart-study-buddy-16111.firebaseapp.com',
    projectId: 'smart-study-buddy-16111',
    storageBucket: 'smart-study-buddy-16111.firebasestorage.app',
    messagingSenderId: '318367609801',
    appId: '1:318367609801:web:c4498bf48c98c01bbcee18',
    measurementId: 'G-8S6D10GN5J',
  );
}
