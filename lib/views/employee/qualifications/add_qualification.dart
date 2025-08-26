import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddQualificationForm extends StatefulWidget {
  const AddQualificationForm({super.key});

  @override
  State<AddQualificationForm> createState() => _AddQualificationFormState();
}

class _AddQualificationFormState extends State<AddQualificationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();

  int? selectedYear;
  File? selectedFile;
  bool isUploading = false;

  // Pick year
  Future<void> _pickYear() async {
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

  // Pick file
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() => selectedFile = File(result.files.single.path!));
    }
  }

  // Convert file to Base64
  Future<String?> _fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedYear == null) {
      Get.snackbar(
        'Error',
        'Please select a year',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedFile == null) {
      Get.snackbar(
        'Error',
        'Please select a certificate',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isUploading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final base64File = await _fileToBase64(selectedFile!);
    if (base64File == null) {
      Get.snackbar(
        'Error',
        'Failed to encode file',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() => isUploading = false);
      return;
    }

    await FirebaseFirestore.instance.collection('qualifications').add({
      'userId': user.uid,
      'qualificationName': _qualificationController.text.trim(),
      'institution': _institutionController.text.trim(),
      'year': selectedYear,
      'serialNumber': _serialNumberController.text.trim(),
      'certificate': base64File,
      'fileName': selectedFile!.path.split('/').last,
      'verificationStatus': 'Pending',
      'createdAt': Timestamp.now(),
    });

    setState(() {
      isUploading = false;
      _qualificationController.clear();
      _institutionController.clear();
      selectedYear = null;
      selectedFile = null;
    });

    Get.snackbar(
      'Success',
      'Qualification added',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Qualification")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(labelText: "Qualification"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter qualification'
                            : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(labelText: "Institution"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter institution'
                            : null,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _pickYear,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Year",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    selectedYear != null
                        ? selectedYear.toString()
                        : "Select Year",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file, color: Colors.blue),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          selectedFile != null
                              ? selectedFile!.path.split('/').last
                              : "Tap to upload certificate",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                selectedFile != null
                                    ? Colors.black
                                    : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _serialNumberController,
                decoration: const InputDecoration(
                  labelText: "Certificate Serial Number",
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter certificate serial number'
                            : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isUploading ? null : _submitForm,
                child: Text(isUploading ? "Uploading..." : "Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
