import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skills_audit_system/widgets/circular_chart.dart';
import 'package:skills_audit_system/widgets/profile_avatar.dart';
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
    // Name: initState
    // Purpose: Initialize the state and load user profile information
    // Parameters: None
    // Returns: None
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    // Name: _loadUserProfile
    // Purpose: Load user profile information from Firestore
    // Parameters: None
    // Returns: None
    if (user != null) {
      // Purpose: Get user document from Firestore
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      if (doc.exists) {
        // Purpose: Extract user information from Firestore document
        final data = doc.data();
        final name = data?['name'] ?? '';
        setState(() {
          // Purpose: Update state with user information
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Get.to(() => const ProfileScreen());
              },
              child: ProfileAvatar(
                radius: 20,
                backgroundColor: const Color.fromARGB(255, 237, 237, 237),
              ),
            ),
          ),
        ],
      ),
      // Drawer now shows profile automatically
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Your personal progress',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'Keep track of your qualifications, skills, and trainings',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),

            // OverallHalfCircleChart(
            //   collections: ["qualifications", "trainings", "skills"],
            //   gradientColors: [
            //     [Colors.green, Colors.lightGreenAccent], // qualifications
            //     [Colors.blue, Colors.lightBlueAccent], // trainings
            //     [Colors.purple, Colors.pinkAccent], // skills
            //   ],
            //   subLabel: "Total Achievements",
            // ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularCountChart(
                  collectionName: "qualifications",
                  label: "Qualifications",
                  total: 10,

                  gradientColors: [
                    Colors.blue,
                    const Color.fromARGB(124, 64, 195, 255),
                  ],
                ),
                CircularCountChart(
                  collectionName: "skills",
                  label: "Skills",
                  total: 20,
                  gradientColors: [
                    Colors.green,
                    const Color.fromARGB(124, 178, 255, 89),
                  ],
                ),
                CircularCountChart(
                  collectionName: "trainings",
                  label: "Trainings",
                  total: 15,
                  gradientColors: [
                    Colors.purple,
                    const Color.fromARGB(119, 255, 64, 128),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Activity Log',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
