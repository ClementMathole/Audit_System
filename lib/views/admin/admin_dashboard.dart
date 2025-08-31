import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Admin Dashboard"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (snapshot.error is FirebaseException &&
                (snapshot.error as FirebaseException).code ==
                    'permission-denied') {
              return const Center(
                child: Text(
                  "Access denied. Admins only.",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            }
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;
          if (users.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unnamed User';
              final email = data['email'] ?? '';
              final adminFlag = data['isAdmin'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    adminFlag ? Icons.admin_panel_settings : Icons.person,
                    color: adminFlag ? Colors.indigo : Colors.grey,
                  ),
                  title: Text(name),
                  subtitle: Text(email),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
