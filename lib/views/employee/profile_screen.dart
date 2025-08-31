import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skills_audit_system/services/user_service.dart';
import 'package:skills_audit_system/views/auth/privacy_policy_screen.dart';
import 'package:skills_audit_system/widgets/profile_avatar.dart';
import '../../widgets/elevated_button.dart';
import '../auth/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService userService = UserService();

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.off(() => const Login());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Logout failed: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(CupertinoIcons.chevron_back, size: 27),
        ),
        title: const Text('Account'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: userService.getUserDataStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var user = snapshot.data!;
            return Column(
              children: [
                Row(
                  children: [
                    ProfileAvatar(
                      radius: 25,
                      backgroundColor: const Color.fromARGB(255, 237, 237, 237),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        Text(
                          user['email'],
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 30),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Contact Information'),
                      Icon(CupertinoIcons.chevron_right),
                    ],
                  ),
                ),
                const Divider(height: 30),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Help Center'),
                      Icon(CupertinoIcons.chevron_right),
                    ],
                  ),
                ),
                const Divider(height: 30),
                GestureDetector(
                  onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Privacy and Consent'),
                      Icon(CupertinoIcons.chevron_right),
                    ],
                  ),
                ),
                const Divider(height: 30),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Report a bug'),
                      Icon(CupertinoIcons.chevron_right),
                    ],
                  ),
                ),
                const Divider(height: 30),
                SizedBox(height: 20),
                PrimaryButton(
                  onPressed: () async => await logout(),
                  text: 'Log Out',
                ),
                SizedBox(height: 50),
                Text('App v1.0.0', style: TextStyle(color: Colors.grey)),
              ],
            );
          },
        ),
      ),
    );
  }
}
