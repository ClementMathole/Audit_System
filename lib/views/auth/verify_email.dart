import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skills_audit_system/views/auth/signup.dart';
import 'package:skills_audit_system/wrapper.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool _emailSent = false;
  Timer? _verificationTimer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    // Purpose: Initialize the state and send verification email
    super.initState();
    _sendVerificationEmail();
    _startVerificationTimer();
  }

  @override
  void dispose() {
    // Purpose: Dispose of the timer when the widget is disposed
    _verificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    // Name: _sendVerificationEmail
    // Purpose: Send a verification email to the user
    // Parameters: None
    // Returns: Future<void>
    if (_emailSent) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      // Purpose: Send email verification
      await user.sendEmailVerification();
      setState(() {
        _emailSent = true;
      });
    }
  }

  void _startVerificationTimer() {
    // Name: _startVerificationTimer
    // Purpose: Start the email verification countdown timer
    // Parameters: None
    // Returns: void
    _verificationTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        // Purpose: User email is verified
        timer.cancel();
        Get.offAll(Wrapper());
        Get.snackbar(
          'Email Verified',
          'Thank you for verifying your email.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      setState(() {
        // Purpose: Update the countdown timer
        _secondsRemaining -= 1;
      });

      if (_secondsRemaining <= 0) {
        // Purpose: Time expired, navigate back to signup
        timer.cancel();
        _navigateBackToSignUp();
      }
    });
  }

  void _navigateBackToSignUp() {
    // Name: _navigateBackToSignUp
    // Purpose: Navigate back to the signup screen
    // Parameters: None
    // Returns: void
    Get.offAll(Signup());
    Get.snackbar(
      'Time Expired',
      'Please sign up again to receive a new verification email.',
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Verify Email"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 64, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                "Please check your email and follow the instructions to verify your account.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "Please verify your email to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 20),
              if (_secondsRemaining > 0)
                Text(
                  "Time remaining: $_secondsRemaining seconds",
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  elevation: 0,
                ),
                onPressed: _sendVerificationEmail,
                label: Text(
                  "Resend Verification Email",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
