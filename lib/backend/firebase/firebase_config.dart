import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAtNZjK7DsJNUI3zLxOPN8vCz-2YcZ7V3w",
            authDomain: "ai-signs2.firebaseapp.com",
            projectId: "ai-signs2",
            storageBucket: "ai-signs2.firebasestorage.app",
            messagingSenderId: "698422389420",
            appId: "1:698422389420:web:f6429b8b26b037f96f4d09",
            measurementId: "G-Z1RS9P5CLS"));
  } else {
    await Firebase.initializeApp();
  }
}
