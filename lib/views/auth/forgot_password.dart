import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:skills_audit_system/views/auth/login.dart';
import 'package:skills_audit_system/widgets/elevated_button.dart';

import '../../widgets/text_form_field.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  reset() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: _emailController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(CupertinoIcons.chevron_back, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Forgot Password?',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Enter the email address associated with your account and we\'ll send you a link to reset your password.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 98, 98, 98),
                  ),
                ),
                SizedBox(height: 20),
                CustomTextFormField(
                  controller: _emailController,
                  label: "Email",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
            Column(
              children: [
                TextButton(
                  onPressed: () => Get.to(() => const Login()),
                  child: const Text(
                    "Remember your password? Login",
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                PrimaryButton(
                  text: 'Reset Password',
                  onPressed: () {
                    if (_emailController.text.isNotEmpty) {
                      reset();
                      Get.snackbar(
                        'Success',
                        'Password reset email sent. Check your inbox.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } else {
                      Get.snackbar(
                        'Error',
                        'Please enter your email address.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
