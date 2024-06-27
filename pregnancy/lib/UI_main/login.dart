import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register.dart'; // Import the RegisterPage class
import 'password_reset.dart'; // Import the PasswordResetPage

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

  void _login() async {
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
        // User found, navigate to HomePage with user ID
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {'userId': uid},
        );
      } else {
        // Show error message if user document does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found in database')),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _login,
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
