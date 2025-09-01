import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'training_form.dart';

class TrainingDetails extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const TrainingDetails({super.key, required this.docId, required this.data});

  Future<void> _deleteTraining(BuildContext context) async {
    await FirebaseFirestore.instance.collection('trainings').doc(docId).delete();
    Get.back();
    Get.snackbar("Deleted", "Training has been removed",
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final trainingName = data['trainingName'] ?? 'Unknown';
    final provider = data['provider'] ?? 'Unknown';
    final status = data['status'] ?? 'Unknown';
    final plannedDate = data['plannedDate'] != null
        ? (data['plannedDate'] as Timestamp).toDate()
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () => Get.back(),
        ),
        title: const Text("Training Details"),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.pencil),
            onPressed: () => Get.to(() => TrainingForm(docId: docId, existingData: data)),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash),
            onPressed: () => _deleteTraining(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Training: $trainingName", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Provider: $provider"),
            Text("Status: $status"),
            if (plannedDate != null)
              Text("Planned Date: ${plannedDate.day}/${plannedDate.month}/${plannedDate.year}"),
          ],
        ),
      ),
    );
  }
}
