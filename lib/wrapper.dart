import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skills_audit_system/views/auth/login.dart';
import 'package:skills_audit_system/views/auth/verify_email.dart';
import 'package:skills_audit_system/views/employee/home_screen.dart';
import 'views/admin/admin_dashboard.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (authSnapshot.hasData) {
            if (!authSnapshot.data!.emailVerified) {
              return const VerifyEmail();
            }
            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(authSnapshot.data!.uid)
                      .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Login();
                }
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final String role = userData['role'] ?? 'employee';

                if (role == 'admin') {
                  return const AdminHomeScreen();
                } else {
                  return const HomeScreen();
                }
              },
            );
          } else {
            return const Login();
          }
        },
      ),
    );
  }
}
