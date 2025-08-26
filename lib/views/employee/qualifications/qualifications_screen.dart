import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'qualification_details.dart';
import 'qualification_form.dart';

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
      // Purpose: Show a message when the user is not logged in
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Qualifications"),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add, size: 27),
            onPressed: () => Get.to(() => const QualificationForm()),
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
            // Purpose: Show a loading indicator while waiting for data
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Purpose: Show an error message if something goes wrong
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            // Purpose: Show a message when no qualifications are found
            return const Center(child: Text("No qualifications submitted."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
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
                elevation: 0,
                margin: const EdgeInsets.all(18),
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
                  onTap: () {
                    // Purpose: Navigate to the qualification details page
                    Get.to(
                      () => QualificationDetails(
                        docId: docs[index].id,
                        data: data,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
