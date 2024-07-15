
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'agency_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'agency_home_page.dart'; // Import AgencyHomePage

class CreateAgencyDialog extends StatefulWidget {
  @override
  _CreateAgencyDialogState createState() => _CreateAgencyDialogState();
}

class _CreateAgencyDialogState extends State<CreateAgencyDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int _currentStep = 0;
  bool _isSubmitting = false; // Flag to prevent multiple submissions

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Create Agency',
        style: TextStyle(color: Colors.orange),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepContent(_currentStep),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 61, 61, 61)),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  child: Text('Back'),
                ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: _isSubmitting ? null : () {
                  if (_currentStep < 2) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    _submitForm();
                  }
                },
                child: Text(_currentStep < 2 ? 'Next' : 'Create Agency'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return TextField(
          controller: _nameController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Agency Name',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
        );
      case 1:
        return TextField(
          controller: _contactController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Contact',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
        );
      case 2:
        return TextField(
          controller: _emailController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
        );
      default:
        return Container();
    }
  }

 void _submitForm() async {
  print('Submitting form...');

  String agencyName = _nameController.text.trim();
  String contact = _contactController.text.trim();
  String email = _emailController.text.trim();

  // Validate input
  if (agencyName.isEmpty || contact.isEmpty || email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }

  print('Form validated.');

  // Prevent multiple submissions
  setState(() {
    _isSubmitting = true;
  });

  // Check if the current user already has an agency
  final currentUser = FirebaseAuth.instance.currentUser;
  final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
  final userDoc = await userRef.get();
  if (userDoc.exists && userDoc.data()!['agency_id'] != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You already have an agency')),
    );
    setState(() {
      _isSubmitting = false; // Reset submission flag
    });
    return;
  }

  print('User checked for existing agency.');

  // Create agency object
  Agency newAgency = Agency(
    agency_name: agencyName,
    contact: contact,
    agency_email: email,
  );

  print('Agency object created: $newAgency');

  // Add agency to Firestore
  try {
    // Create a new document in 'agencies' collection with a generated ID
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('agencies')
        .add({
      'agency_name': newAgency.agency_name,
      'contact': newAgency.contact,
      'agency_email': newAgency.agency_email,
      'created_by': currentUser.uid, // Associate agency with user ID
    });

    print('Agency added to Firestore: ${docRef.id}');

    // Update user document with agency ID
    await userRef.update({'agency_id': docRef.id});

    print('User document updated with agency ID.');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agency created successfully')),
    );

    // Close dialog and navigate to AgencyHomePage after creating agency
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AgencyHomePage()),
    );
  } catch (e) {
    // Handle Firestore error
    print('Error creating agency: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create agency')),
    );
  } finally {
    setState(() {
      _isSubmitting = false; // Reset submission flag
    });
  }
}

  void showCreateAgencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateAgencyDialog();
      },
    );
  }
}