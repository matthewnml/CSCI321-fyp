import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'UI_main/login.dart';
import 'firebase_options.dart'; // Import the Firebase options
import 'UI_3/health.dart'; // Import the health.dart file
import 'UI_1/home.dart'; // Import the home.dart file

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
        scaffoldBackgroundColor: const Color(0xFFfdebeb), // Custom background color
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        //'/calendar': (context) => CalendarScreen(), // Define CalendarScreen
        '/health': (context) => const HealthScreen(),
        //'/settings': (context) => SettingsScreen(), // Define SettingsScreen
      },
    );
  }
}

