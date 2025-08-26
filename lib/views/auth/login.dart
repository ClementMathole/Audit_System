import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skills_audit_system/views/auth/forgot_password.dart';
import 'package:skills_audit_system/views/auth/signup.dart';

import '../../widgets/elevated_button.dart';
import '../../widgets/text_form_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 50),
                Image.asset('assets/logo.png', width: 150),
                SizedBox(height: 50),
                Text('Welcome Back!', style: TextStyle(fontSize: 25)),
                Text(
                  'Please enter your credentials to continue.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 50),
                CustomTextFormField(
                  controller: _emailController,
                  label: "Email",
                  keyboardType: TextInputType.emailAddress,
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
                SizedBox(height: 20),
                CustomTextFormField(
                  controller: _passwordController,
                  label: "Password",
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                PrimaryButton(
                  text: "Login",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                      } on FirebaseAuthException catch (e) {
                        String message = 'An error occurred';
                        if (e.code == 'user-not-found') {
                          message = 'No user found for that email.';
                        } else if (e.code == 'wrong-password') {
                          message = 'Wrong password provided.';
                        }
                        Get.snackbar(
                          'Error',
                          message,
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.to(() => const ForgotPassword()),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.to(() => const Signup()),
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
