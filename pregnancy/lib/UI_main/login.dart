import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for storing lockout data
import 'register.dart'; // Import the RegisterPage class
import 'password_reset.dart'; // Import the PasswordResetPage
import 'dart:async'; // Import for Timer

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _failedAttempts = 0;
  bool _isLockedOut = false;
  DateTime? _lockoutEndTime;
  Timer? _lockoutTimer;
  String _lockoutTimeRemaining = '';

  @override
  void initState() {
    super.initState();
    _checkLockoutStatus();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _checkLockoutStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutEndTimestamp = prefs.getInt('lockoutEndTime');
    if (lockoutEndTimestamp != null) {
      _lockoutEndTime = DateTime.fromMillisecondsSinceEpoch(lockoutEndTimestamp);
      if (_lockoutEndTime!.isAfter(DateTime.now())) {
        setState(() {
          _isLockedOut = true;
        });
        _startLockoutTimer();
      } else {
        prefs.remove('lockoutEndTime');
      }
    }
  }

  void _startLockoutTimer() {
    final duration = _lockoutEndTime!.difference(DateTime.now());
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remainingDuration = _lockoutEndTime!.difference(DateTime.now());
      if (remainingDuration.isNegative) {
        timer.cancel();
        setState(() {
          _isLockedOut = false;
          _failedAttempts = 0;
          _lockoutTimeRemaining = '';
        });
      } else {
        setState(() {
          _lockoutTimeRemaining = _formatDuration(remainingDuration);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _login() async {
    if (_isLockedOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Too many failed attempts. Please try again later. $_lockoutTimeRemaining remaining')),
      );
      return;
    }

    try {
      // Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Get the UID of the authenticated user
      String uid = userCredential.user!.uid;

      // Fetch user data from Firestore using the UID
      DocumentSnapshot userDoc = await _firestore.collection('user_accounts').doc(uid).get();

      if (userDoc.exists) {
        // User found, navigate to HomePage with user ID and pregnancy status
        String pregnancyStatus = userDoc['pregnancy_status'];
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {'userId': uid, 'pregnancyStatus': pregnancyStatus},
        );
      } else {
        // Show error message if user document does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found in database')),
        );
      }
    } catch (e) {
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        _lockoutUser();
      }
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _lockoutUser() async {
    const lockoutDuration = Duration(seconds: 30);
    _lockoutEndTime = DateTime.now().add(lockoutDuration);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lockoutEndTime', _lockoutEndTime!.millisecondsSinceEpoch);
    setState(() {
      _isLockedOut = true;
    });
    _startLockoutTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 100, // Set your desired width
              height: 100, // Set your desired height
              child: Image.asset('assets/logo.png'), // Replace with your actual image path
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PasswordResetPage()),
                );
              },
              child: const Text('Forgot Password?'),
            ),
            if (_isLockedOut) ...[
              const SizedBox(height: 10),
              Text('Too many failed attempts. Try again in $_lockoutTimeRemaining.',
                  style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLockedOut ? null : _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to the register page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFfdebeb),
    );
  }
}