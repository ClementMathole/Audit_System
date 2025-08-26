import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'employee_detail.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("users")
                .where("role", isEqualTo: "employee") // ✅ show only employees
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No employees found."));
          }

          final employees = snapshot.data!.docs;

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              final employeeId = employee.id;

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(employee['name'] ?? "No Name"),
                subtitle: Text(employee['email']),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EmployeeQualificationsPage(
                            employeeId: employeeId,
                            employeeName: employee['name'],
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Example logout using FirebaseAuth
          // import 'package:firebase_auth/firebase_auth.dart'; at the top if not already
          await FirebaseAuth.instance.signOut();
          // Optionally navigate to login screen
          //Navigator.of(context).pushReplacementNamed('/login');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
