import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'qualification_form.dart';

class QualificationDetails extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const QualificationDetails({
    // Name: QualificationDetails
    // Purpose: Constructor for QualificationDetails
    // Parameters:
    //   - Key? key: The widget key
    //   - String docId: The document ID of the qualification
    //   - Map<String, dynamic> data: The qualification data
    super.key,
    required this.docId,
    required this.data,
  });

  Future<void> _deleteQualification(BuildContext context) async {
    // Name: _deleteQualification
    // Purpose: Delete a qualification document
    // Parameters: BuildContext context - the build context
    // Returns: None
    await FirebaseFirestore.instance
        .collection('qualifications')
        .doc(docId)
        .delete();

    Get.back();
    Get.snackbar(
      "Deleted",
      "Qualification has been removed",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final qualificationName = data['qualificationName'] ?? 'Unknown';
    final institution = data['institution'] ?? 'Unknown';
    final year = data['year']?.toString() ?? 'Unknown';
    final serialNumber = data['serialNumber'] ?? 'Unknown';
    final verificationStatus = data['verificationStatus'] ?? 'Pending';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, size: 27),
          onPressed: () => Get.back(),
        ),
        title: const Text("Qualification Details"),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.pencil),
            onPressed: () {
              Get.to(() => QualificationForm(docId: docId, existingData: data));
            },
          ),

          IconButton(
            icon: const Icon(CupertinoIcons.trash),
            onPressed: () => _deleteQualification(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Qualification: $qualificationName",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text("Institution: $institution"),
            Text("Year: $year"),
            Text("Serial Number: $serialNumber"),
            const SizedBox(height: 10),
            Text(
              "Status: $verificationStatus",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
