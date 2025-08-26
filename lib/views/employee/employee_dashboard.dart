import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_screen.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final user = FirebaseAuth.instance.currentUser;
  String? firstName;
  String? email;
  String? fullName;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      if (doc.exists) {
        final data = doc.data();
        final name = data?['name'] ?? '';
        setState(() {
          fullName = name;
          firstName = name.toString().split(' ').first;
          email = data?['email'] ?? user!.email;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(firstName != null ? 'Hello, $firstName' : 'Hello...'),
      ),

      // Drawer now shows profile automatically
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => const ProfileScreen());
              },
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.blueGrey),
                accountName: Text(fullName ?? "Loading..."),
                accountEmail: Text(email ?? "Loading..."),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(
                    Icons.account_circle,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Welcome to the Employee Dashboard')),
    );
  }
}
