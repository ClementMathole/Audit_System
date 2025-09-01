import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/text_form_field.dart';

class QualificationForm extends StatefulWidget {
  final String? docId; // if null -> Add, else -> Edit
  final Map<String, dynamic>? existingData;

  const QualificationForm({super.key, this.docId, this.existingData});

  @override
  State<QualificationForm> createState() => _QualificationFormState();
}

class _QualificationFormState extends State<QualificationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();

  int? selectedYear;
  File? selectedFile;
  bool isUploading = false;

  @override
  void initState() {
    // Name: initState
    // Purpose: Initialize form fields with existing data if available
    // Parameters: None
    // Returns: None
    super.initState();
    if (widget.existingData != null) {
      // Populate fields with existing data
      _qualificationController.text =
          widget.existingData!['qualificationName'] ?? '';
      _institutionController.text = widget.existingData!['institution'] ?? '';
      _serialNumberController.text = widget.existingData!['serialNumber'] ?? '';
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

  Future<void> _pickFile() async {
    // Name: _pickFile
    // Purpose: Show a file picker dialog
    // Parameters: None
    // Returns: None
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      // Purpose: Set the selected file
      setState(() => selectedFile = File(result.files.single.path!));
    }
  }

  Future<String?> _fileToBase64(File file) async {
    // Name: _fileToBase64
    // Purpose: Convert a file to a Base64 string
    // Parameters: File file - the file to convert
    // Returns: Future<String?> - the Base64 string or null if failed
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitForm() async {
    // Name: _submitForm
    // Purpose: Submit the qualification form
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

    setState(() => isUploading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? base64File;
    if (selectedFile != null) {
      // Purpose: Convert the selected file to a Base64 string
      base64File = await _fileToBase64(selectedFile!);
      if (base64File == null) {
        // Purpose: Show an error message if file encoding fails
        Get.snackbar(
          "Error",
          "Failed to encode file",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() => isUploading = false);
        return;
      }
    }

    final data = {
      // Purpose: Prepare the qualification data for submission
      'userId': user.uid,
      'qualificationName': _qualificationController.text.trim(),
      'institution': _institutionController.text.trim(),
      'year': selectedYear,
      'serialNumber': _serialNumberController.text.trim(),
      'updatedAt': Timestamp.now(),
    };

    if (base64File != null) {
      // Purpose: Include file data if a new file was selected
      data['certificate'] = base64File;
      data['fileName'] = selectedFile!.path.split('/').last;
    }

    if (widget.docId == null) {
      // Purpose: Add a new qualification
      await FirebaseFirestore.instance.collection('qualifications').add({
        ...data,
        'verificationStatus': 'Pending',
        'createdAt': Timestamp.now(),
      });

      Get.snackbar(
        "Success",
        "Qualification added",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      // Purpose: Update/Edit an existing qualification
      await FirebaseFirestore.instance
          .collection('qualifications')
          .doc(widget.docId)
          .update(data);

      Get.snackbar(
        "Success",
        "Qualification updated",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }

    setState(() => isUploading = false);
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
        title: Text(isEdit ? "Edit Qualification" : "Add Qualification"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextFormField(
                controller: _qualificationController,
                label: "Qualification",
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter qualification'
                            : null,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _institutionController,
                label: "Institution",
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
                              : (isEdit
                                  ? "Tap to change certificate (optional)"
                                  : "Tap to upload certificate"),
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
              CustomTextFormField(
                controller: _serialNumberController,
                label: "Certificate Serial Number",
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter certificate serial number'
                            : null,
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
                  if (isUploading) return;

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
                child: Text(
                  isUploading ? "Uploading..." : (isEdit ? "Update" : "Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
