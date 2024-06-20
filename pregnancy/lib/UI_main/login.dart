import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../UI_1/home.dart';
import 'register.dart'; // Import the RegisterPage class

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _login() async {
    try {
      QuerySnapshot result = await _firestore
          .collection('user_accounts')
          .where('user_id', isEqualTo: _usernameController.text)
          .where('password', isEqualTo: _passwordController.text)
          .get();

      if (result.docs.isNotEmpty) {
        // User found, navigate to HomePage with user ID
        String userId = result.docs.first.get('user_id');
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {'userId': userId},
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
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
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
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
                // Implement what happens when users forget their password
                print('Forgot Password Clicked');
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
