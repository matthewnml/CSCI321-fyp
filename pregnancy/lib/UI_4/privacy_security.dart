// UI_4/privacy_security.dart
import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '1. Introduction\n'
                      'Welcome to our pregnancy app. By using this app, you agree to comply with and be bound by the following terms and conditions of use, which together with our privacy policy govern our relationship with you in relation to this app.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '2. Use of the App\n'
                      'This app is intended for educational and informational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '3. User Account\n'
                      'To use certain features of the app, you may need to register and create an account. You agree to provide accurate and complete information and to keep this information up to date. You are responsible for maintaining the confidentiality of your account and password.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '4. Privacy\n'
                      'We are committed to protecting your privacy. All personal data that you provide to us will be handled in accordance with our privacy policy.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '5. Intellectual Property\n'
                      'All content included on the app, such as text, graphics, logos, images, and software, is the property of the app developers or its content suppliers and is protected by intellectual property laws.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '6. Limitation of Liability\n'
                      'We will not be liable for any loss or damage arising from your use of the app, including but not limited to any direct, indirect, incidental, punitive, or consequential damages.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '7. Changes to Terms & Conditions\n'
                      'We may update these terms and conditions from time to time. Any changes will be posted on this page, and you are encouraged to review these terms and conditions regularly.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '8. Contact Us\n'
                      'If you have any questions about these terms and conditions, please contact us at support@babybump.com.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle agreement to terms and conditions
                Navigator.pop(context);
              },
              child: const Text('Agree to Terms and Conditions'),
            ),
          ],
        ),
      ),
    );
  }
}
