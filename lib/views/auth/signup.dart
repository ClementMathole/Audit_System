import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skills_audit_system/wrapper.dart';
import 'package:skills_audit_system/widgets/privacy_checkbox.dart';

import '../../widgets/text_form_field.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool accepted = false;

  Future<void> _signupUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'All fields are required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters long',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      if (userCredential.user != null) {
        await _createUserData(userCredential.user!);
      }

      Get.offAll(() => const Wrapper());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Signup Failed',
        e.message ?? 'An unknown error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _createUserData(User user) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    await usersCollection.doc(user.uid).set({
      'uid': user.uid,
      'name': _nameController.text.trim(),
      'email': user.email,
      'role': 'employee',
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, size: 27),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Image.asset('assets/logo.png', width: 150),
              SizedBox(height: 30),
              const Text('Sign Up', style: TextStyle(fontSize: 25)),
              const Text(
                'Create an account to get started.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              CustomTextFormField(
                controller: _nameController,
                label: "Full Name",
              ),
              SizedBox(height: 20),
              CustomTextFormField(controller: _emailController, label: "Email"),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _passwordController,
                label: "Password",
                obscureText: true,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _confirmPasswordController,
                label: "Confirm Password",
                obscureText: true,
              ),
              SizedBox(height: 20),
              PrivacyPolicyCheckbox(
                initialValue: accepted,
                onChanged: (v) {
                  setState(() => accepted = v);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  elevation: 0,
                ),
                onPressed: accepted ? _signupUser : null,
                child: const Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
