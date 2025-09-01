import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/text_form_field.dart';

class SkillForm extends StatefulWidget {
  final String? docId; // if null -> Add, else -> Edit
  final Map<String, dynamic>? existingData;

  const SkillForm({super.key, this.docId, this.existingData});

  @override
  State<SkillForm> createState() => _SkillFormState();
}

class _SkillFormState extends State<SkillForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _skillNameController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  int? selectedYear;

  @override
  void initState() {
    // Name: initState
    // Purpose: Initialize form fields with existing data if available
    // Parameters: None
    // Returns: None
    super.initState();
    if (widget.existingData != null) {
      // Populate fields with existing data
      _skillNameController.text = widget.existingData!['skillName'] ?? '';
      _providerController.text = widget.existingData!['provider'] ?? '';
      _yearController.text = widget.existingData!['year']?.toString() ?? '';
      selectedYear = widget.existingData!['year'];
    }
  }

  Future<void> _pickYear() async {
    // Name: _pickYear
    // Purpose: Show a year picker dialog
    // Parameters: None
    // Returns: None
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year),
      firstDate: DateTime(1900),
      lastDate: DateTime(today.year + 10),
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    if (picked != null) setState(() => selectedYear = picked.year);
  }

  Future<void> _submitForm() async {
    // Name: _submitForm
    // Purpose: Submit the skill form
    // Parameters: None
    // Returns: None
    if (!_formKey.currentState!.validate()) return;
    if (selectedYear == null) {
      // Purpose: Show an error message if year is not selected
      Get.snackbar(
        "Error",
        "Please select a year",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = {
      // Purpose: Prepare the skill data for submission
      'userId': user.uid,
      'skillName': _skillNameController.text.trim(),
      'provider': _providerController.text.trim(),
      'year': selectedYear,
      'updatedAt': Timestamp.now(),
    };

    if (widget.docId == null) {
      // Purpose: Add a new skill
      await FirebaseFirestore.instance.collection('skills').add({
        ...data,
        'userId': user.uid,
        'createdAt': Timestamp.now(),
      });

      Get.snackbar(
        "Success",
        "Skill added",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      // Purpose: Update/Edit an existing skill
      await FirebaseFirestore.instance
          .collection('skills')
          .doc(widget.docId)
          .update(data);

      Get.snackbar(
        "Success",
        "Skill updated",
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
        title: Text(isEdit ? "Edit Skill" : "Add Skill"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextFormField(
                controller: _skillNameController,
                label: "Skill",
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter skill' : null,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _providerController,
                label: "Provider",
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter provider'
                            : null,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _pickYear,
                child: InputDecorator(
                  decoration: InputDecoration(
                    fillColor: const Color.fromARGB(128, 238, 238, 238),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  child: Text(
                    selectedYear != null
                        ? selectedYear.toString()
                        : "Select Year",
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm();
                    Navigator.of(context).pop();
                  } else {
                    Get.snackbar(
                      "Error",
                      "Please fill in all required fields",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red.shade600,
                      colorText: Colors.white,
                    );
                  }
                },
                child: Text((isEdit ? "Update" : "Submit")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
