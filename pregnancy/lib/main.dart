import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'firebase_options.dart'; // Import the Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Initialize Firebase for web
    await Firebase.initializeApp(
      options: firebaseOptions,
    );
  } else {
    // Initialize Firebase for mobile (Android, iOS)
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pregnancy App',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFfdebeb), // Custom background color
      ),
      home: const LoginPage(),
    );
  }
}
