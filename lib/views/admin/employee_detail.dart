import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployeeQualificationsPage extends StatelessWidget {
  final String employeeId;
  final String employeeName;

  const EmployeeQualificationsPage({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$employeeName's Qualifications")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("users")
                .doc(employeeId)
                .collection("qualifications") // ✅ fetch their qualifications
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No qualifications found."));
          }

          final qualifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: qualifications.length,
            itemBuilder: (context, index) {
              final qualification = qualifications[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(qualification['qualificationName']),
                  subtitle: Text(
                    "Serial No: ${qualification['serialNumber']}\n"
                    "Status: ${qualification['status']}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(employeeId)
                              .collection("qualifications")
                              .doc(qualification.id)
                              .update({"status": "approved"});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(employeeId)
                              .collection("qualifications")
                              .doc(qualification.id)
                              .update({"status": "rejected"});
                        },
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
