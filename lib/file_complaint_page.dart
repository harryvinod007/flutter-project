import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'submission_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FileComplaintPage extends StatefulWidget {
  const FileComplaintPage({Key? key}) : super(key: key);

  @override
  _FileComplaintPageState createState() => _FileComplaintPageState();
}

class _FileComplaintPageState extends State<FileComplaintPage> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _culpritsController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  XFile? _mediaFile;

  final _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime _selectedDate = DateTime.now();
  String? _uploadedMediaUrl; // Variable to store the uploaded media URL
  bool isSubmitting = false;

  final int maxFileSize = 10 * 1024 * 1024;

  String? _selectedDepartment;
  final List<String> _departments = [
    'HR',
    'Engineering',
    'Sales',
    'Marketing',
    'Finance',
    'IT',
    'Research',
    'Customer Support',
    'Legal',
    'Operations',
    'Procurement'
  ];


  Future<List<String>> _fetchEmployeeNames(String query) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('employees').get();

    // Filter and return names and departments based on the query
    final List<String> employeeNames = snapshot.docs
        .map((doc) => doc['name'] as String) // Extract only the 'name' field
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return employeeNames;
  }



  // Function to select date
  // Function to select date
  // Function to select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Restrict to today or earlier
    );
    if (picked != null) {
      setState(() {
        _dateController.text = _dateFormat.format(picked);
        _selectedDate = picked; // Store the selected date for time validation
      });
    }
  }

// Function to select time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final pickedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        picked.hour,
        picked.minute,
      );

      // Check if the selected date is today
      final isToday = _selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day;

      if (isToday && pickedDateTime.isAfter(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Future time is not allowed.')),
        );
        setState(() {
          _timeController.text = ''; // Clear the Time of Occurrence field
        });
        return;
      }

      setState(() {
        _timeController.text = picked.format(context); // Set valid time
      });
    }
  }





  // Function to select media
  Future<void> _selectMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      if (await file.length() > maxFileSize) {
        // Show an error if the file exceeds the size limit
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File size exceeds 10 MB. Please select a smaller file.')),
        );
      } else {
        setState(() {
          _mediaFile = pickedFile;
        });
      }
    }
  }

  Future<String?> _uploadMedia(File mediaFile) async {
    try {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
      final storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

      // Define metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg', // or appropriate MIME type
      );

      // Upload file with metadata
      await storageRef.putFile(mediaFile, metadata);

      // Get and return the download URL
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading media: $e');
      return null;
    }
  }


  // Function to validate and submit the form
  String generateComplaintId() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const length = 8; // Fixed length for complaint ID
    final random = Random();

    return '#${String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    )}';
  }

  // Function to generate a unique token number
  String generateTokenNumber() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const length = 6; // Fixed length for token number
    final random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }


  void _submitForm() async {
    if (isSubmitting) return; // Prevent multiple submissions

    if (_formKey.currentState!.validate()) {
      setState(() {
        isSubmitting = true; // Disable further submissions
      });

      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        String complaintId = generateComplaintId();
        String tokenNumber = generateTokenNumber();

        if (_mediaFile != null) {
          _uploadedMediaUrl = await _uploadMedia(File(_mediaFile!.path));
        }
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        String? token = await messaging.getToken();
        if (token == null) {
          print('Failed to retrieve FCM token.');
        }
        Map<String, dynamic> complaintData = {
          'complaintId': complaintId,
          'folderId': '',
          'tokenNumber': tokenNumber,
          'description': _descriptionController.text.trim(),
          'category': 'General',
          'reporterToken':token,
          'dateOfOccurrence': _dateController.text.trim(),
          'timeOfOccurrence': _timeController.text.trim(),
          'title': _titleController.text.trim(),
          'culprits': _culpritsController.text.trim().isNotEmpty
              ? _culpritsController.text.trim()
              : null,
          'department': _selectedDepartment,
          'media': _uploadedMediaUrl,
          'dateFiled': DateTime.now().toIso8601String(),
          'chatSession': {
            'scheduledTime': null,
            'status': 'Pending',
            'messages': [],
          },
          'decision': {
            'decisionText': '',
            'decisionDate': '',
          },
          'status': {
            'statusText': 'Pending',
            'resolution': '',
          },
        };

        await firestore.collection('complaints').doc(complaintId).set(complaintData);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmissionPage(
              complaintId: complaintId,
              tokenNumber: tokenNumber,
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting complaint: $e')),
        );
      } finally {
        setState(() {
          isSubmitting = false; // Re-enable submissions
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF34495e), Color(0xFF2c3e50)], // Gradient colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Wrap the form with a GlobalKey
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Heading at the top
                    const Text(
                      'File Complaint',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Complaint Title',
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Complaint Title is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _culpritsController,
                        decoration: const InputDecoration(
                          labelText: 'Culprits (optional)',
                          labelStyle: TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      suggestionsCallback: (query) {
                        return _fetchEmployeeNames(query); // This now returns a List<String>
                      },
                      itemBuilder: (context, String suggestion) {
                        return ListTile(
                          title: Text(suggestion), // Directly display the string suggestion
                        );
                      },
                      onSuggestionSelected: (String suggestion) {
                        _culpritsController.text = suggestion; // Directly set the string
                      },
                      noItemsFoundBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No such employee found',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),


                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Department Involved (Optional)',
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true, // Ensures dropdown matches the field's width
                      items: _departments.map((String department) {
                        return DropdownMenuItem<String>(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDepartment = newValue;
                        });
                      },
                      validator: (value) {
                        return null; // Optional validation logic
                      },
                      dropdownColor: Colors.white, // Background color of the dropdown
                    ),




                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Date of Occurrence',
                            labelStyle: TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Date of Occurrence is required.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _timeController,
                          decoration: const InputDecoration(
                            labelText: 'Time of Occurrence',
                            labelStyle: TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _selectMedia,
                      child: Text(
                        _mediaFile == null
                            ? 'Select Media (Optional)'
                            : 'Change Media',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _mediaFile != null
                        ? Text(
                      'Selected: ${_mediaFile!.name}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    )
                        : const Text(
                      'No media file selected',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: SizedBox(
                        width: 200, // Fixed width
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSubmitting?const Color(0xFF2c3e50):Color(0xFF1abc9c), // Updated button background color
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: isSubmitting ? null : _submitForm,
                          child: isSubmitting
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Submitting...'),
                            ],
                          )
                              : const Text('Submit'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
