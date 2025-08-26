import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_qualification.dart';

class QualificationsScreen extends StatefulWidget {
  const QualificationsScreen({super.key});

  @override
  State<QualificationsScreen> createState() => _QualificationsScreenState();
}

class _QualificationsScreenState extends State<QualificationsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Qualifications"),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add, size: 27),
            onPressed: () => Get.to(() => const AddQualificationForm()),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('qualifications')
                .where('userId', isEqualTo: user!.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No qualifications submitted."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // Defensive checks
              final qualificationName = data['qualificationName'] ?? 'Unknown';
              final institution = data['institution'] ?? 'Unknown';
              final year = data['year']?.toString() ?? 'Unknown';
              final serialNumber = data['serialNumber'] ?? 'Unknown';
              final verificationStatus =
                  data['verificationStatus'] ?? 'Pending';

              Color statusColor;
              if (verificationStatus == 'Approved') {
                statusColor = Colors.green;
              } else if (verificationStatus == 'Rejected') {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.orange;
              }

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(qualificationName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Institution: $institution"),
                      Text("Year: $year"),
                      Text("Certificate Serial: $serialNumber"),
                      Text(
                        "Status: $verificationStatus",
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
