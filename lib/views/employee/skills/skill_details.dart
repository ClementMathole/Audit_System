import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'skill_form.dart';

class SkillDetails extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const SkillDetails({
    // Name: SkillDetails
    // Purpose: Constructor for SkillDetails
    // Parameters:
    //   - Key? key: The widget key
    //   - String docId: The document ID of the skill
    //   - Map<String, dynamic> data: The skill data
    super.key,
    required this.docId,
    required this.data,
  });

  Future<void> _deleteSkill(BuildContext context) async {
    // Name: _deleteSkill
    // Purpose: Delete a skill document
    // Parameters: BuildContext context - the build context
    // Returns: None
    await FirebaseFirestore.instance.collection('skills').doc(docId).delete();

    Get.back();
    Get.snackbar(
      "Deleted",
      "Skill has been removed",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final skillName = data['skillName'] ?? 'Unknown';
    final provider = data['provider'] ?? 'Unknown';
    final year = data['year']?.toString() ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, size: 27),
          onPressed: () => Get.back(),
        ),
        title: const Text("Skill Details"),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.pencil),
            onPressed: () {
              Get.to(() => SkillForm(docId: docId, existingData: data));
            },
          ),

          IconButton(
            icon: const Icon(CupertinoIcons.trash),
            onPressed: () => _deleteSkill(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Skill: $skillName", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Provider: $provider"),
            Text("Year: $year"),
          ],
        ),
      ),
    );
  }
}
