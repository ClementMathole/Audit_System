import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This privacy policy explains how we collect, use, and protect your personal information when you use our app.\n\n'
            '1. Information We Collect:\n'
            '- Personal Information: We may collect personal information such as your name, email address, and contact details when you register or use certain features of the app.\n'
            '- Usage Data: We may collect information about how you use the app, including your interactions with features and services.\n\n'
            '2. How We Use Your Information:\n'
            '- To Provide Services: We use your information to provide and improve our services, respond to your inquiries, and personalize your experience.\n'
            '- Communication: We may use your contact information to send you updates, newsletters, and promotional materials related to the app.\n\n'
            '3. Data Security:\n'
            '- We implement appropriate security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.\n\n'
            '4. Third-Party Services:\n'
            '- We may share your information with trusted third-party service providers who assist us in operating the app and providing services to you.\n\n'
            '5. Your Choices:\n'
            '- You can choose not to provide certain personal information, but this may limit your ability to use certain features of the app.\n\n'
            '6. Changes to This Policy:\n'
            '- We may update this privacy policy from time to time. Any changes will be posted on this page with an updated effective date.\n\n'
            'If you have any questions or concerns about our privacy practices, please contact us at capableza@support.com.',
          ),
        ),
      ),
    );
  }
}
