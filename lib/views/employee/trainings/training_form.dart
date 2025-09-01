import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrainingForm extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const TrainingForm({super.key, this.docId, this.existingData});

  @override
  State<TrainingForm> createState() => _TrainingFormState();
}

class _TrainingFormState extends State<TrainingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _trainingNameController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();

  String? selectedStatus;
  DateTime? plannedDate;

  final List<String> statuses = ["Completed", "In Progress", "Planned"];

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _trainingNameController.text = widget.existingData!['trainingName'] ?? '';
      _providerController.text = widget.existingData!['provider'] ?? '';
      selectedStatus = widget.existingData!['status'];
      if (widget.existingData!['plannedDate'] != null) {
        plannedDate =
            (widget.existingData!['plannedDate'] as Timestamp).toDate();
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: plannedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => plannedDate = picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedStatus == "Planned" && plannedDate == null) {
      Get.snackbar(
        "Error",
        "Please select a planned date",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = {
      'userId': user.uid,
      'trainingName': _trainingNameController.text.trim(),
      'provider': _providerController.text.trim(),
      'status': selectedStatus,
      'plannedDate':
          plannedDate != null ? Timestamp.fromDate(plannedDate!) : null,
      'updatedAt': Timestamp.now(),
    };

    if (widget.docId == null) {
      await FirebaseFirestore.instance.collection('trainings').add({
        ...data,
        'createdAt': Timestamp.now(),
      });
      Get.snackbar(
        "Success",
        "Training added",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      await FirebaseFirestore.instance
          .collection('trainings')
          .doc(widget.docId)
          .update(data);
      Get.snackbar(
        "Success",
        "Training updated",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.docId != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, size: 27),
          onPressed: () => Get.back(),
        ),
        title: Text(isEdit ? "Edit Training" : "Add Training"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _trainingNameController,
                decoration: const InputDecoration(labelText: "Training Name"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Enter training name"
                            : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _providerController,
                decoration: const InputDecoration(labelText: "Provider"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Enter provider"
                            : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items:
                    statuses
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
                decoration: const InputDecoration(labelText: "Status"),
                validator:
                    (value) => value == null ? "Please select status" : null,
              ),
              if (selectedStatus == "Planned") ...[
                const SizedBox(height: 20),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Planned Start Date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      plannedDate != null
                          ? "${plannedDate!.day}/${plannedDate!.month}/${plannedDate!.year}"
                          : "Select Date",
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submitForm,
                child: Text(isEdit ? "Update" : "Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
