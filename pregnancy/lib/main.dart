import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'UI_main/login.dart';
import 'firebase_options.dart'; // Import the Firebase options
import 'UI_3/health.dart'; // Import the health.dart file
import 'UI_1/home.dart'; // Import the home.dart file
import 'UI_2/calendar.dart'; // Import the calendar.dart file
import 'UI_4/setting.dart'; // Import the setting.dart file
import 'UI_4/account.dart'; // Import the account.dart file
import 'UI_4/notifications.dart'; // Import the notifications.dart file
import 'UI_4/privacy_security.dart'; // Import the privacy_security.dart file
import 'UI_4/emergency_contact.dart'; // Import the emergency_contact.dart file
import 'UI_main/password_reset.dart'; // Import the password_reset.dart file


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
        scaffoldBackgroundColor:
            const Color(0xFFfdebeb), // Custom background color
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/calendar': (context) => const CalendarScreen(),
        '/health': (context) => const HealthScreen(),
        '/setting': (context) => const SettingsScreen(userId: ''), // Temporary userId for settings screen
        '/notifications': (context) => const NotificationsPage(),
        '/terms_conditions': (context) => const TermsAndConditionsPage(),
        '/emergency-contact': (context) => const EmergencyContactPage(), // Add this route
        '/password-reset': (context) => const PasswordResetPage(), // Add password reset route
      },
      // Routes that require userId
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return HomePage(userId: args['userId']);
            },
          );
        }
        if (settings.name == '/account') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return AccountPage(userId: args['userId']);
            },
          );
        }
        // Add other dynamic routes here if needed
        return null; // Let `onUnknownRoute` handle this
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginPage());
      },
    );
  }
}
