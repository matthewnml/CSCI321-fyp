import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'UI_main/login.dart';
import 'firebase_options.dart';
import 'UI_3/health_user.dart';
import 'UI_1/home_during.dart';
import 'UI_1/home_after.dart';
import 'UI_1/home_before.dart';
import 'UI_1/home_special.dart';
import 'UI_2/calendar.dart';
import 'UI_4/setting.dart';
import 'UI_4/account.dart';
import 'UI_4/contact_us.dart';
import 'UI_4/notifications.dart';
import 'UI_4/notificationpage.dart';
import 'UI_4/privacy_security.dart';
import 'UI_4/emergency_contact.dart';
import 'UI_main/password_reset.dart';
import 'UI_1/admin.dart'; // Import the admin.dart file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // Initialize Firebase for web
      await Firebase.initializeApp(
        options: firebaseOptions,
      );
    } else {
      // Initialize Firebase for mobile (Android, iOS)
      await Firebase.initializeApp();
    }

    NotificationService notificationService = NotificationService();
    await notificationService.init();

    runApp(const MyApp());
  } catch (e) {
    print('Error during main initialization: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pregnancy App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFfdebeb),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingPage(),
        '/login': (context) => const LoginPage(),
        '/calendar': (context) => const CalendarScreen(),
        '/health': (context) => const HealthScreen(),
        '/setting': (context) => const SettingsScreen(userId: ''), // Temporary userId for settings screen
        '/notifications': (context) => NotificationPage(), // Removed const here
        '/terms_conditions': (context) => const TermsAndConditionsPage(),
        '/emergency-contact': (context) => const EmergencyContactPage(),
        '/password-reset': (context) => const PasswordResetPage(),
        '/contact_us': (context) => const ContactUsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>;
          final userId = args['userId'];
          return MaterialPageRoute(
            builder: (context) => HomePage(userId: userId),
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

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize Firebase and request permissions
    try {
      print('Initializing Firebase...');
      await Firebase.initializeApp();
      print('Firebase initialized.');
      await _requestPermissions();
      print('Permissions requested.');

      // Navigate to the login page
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print('Error during initialization: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print('Error during permission request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String userId;

  const HomePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('user_accounts').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const LoginPage();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final pregnancyStatus = userData['pregnancy_status'];
        final role = userData['role'];

        Widget homePage;

        if (role == 'Admin') {
          homePage = AdminDashboard(userId: userId);
        } else if (pregnancyStatus == 'Trying to conceive') {
          homePage = HomeBeforePage(userId: userId);
        } else if (pregnancyStatus == 'Currently pregnant') {
          homePage = HomeDuringPage(userId: userId);
        } else if (pregnancyStatus == 'Have given birth') {
          homePage = HomeAfterPage(userId: userId);
        } else if (pregnancyStatus == 'None(For Specialist)') {
          homePage = HomeSpecialistPage(userId: userId);
        } else {
          homePage = const LoginPage(); // Default case, shouldn't happen
        }

        return homePage;
      },
    );
  }
}
