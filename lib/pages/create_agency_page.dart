import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'agency_model.dart';
import 'agency_home_page.dart'; // Import AgencyHomePage

class CreateAgencyPage extends StatefulWidget {
  @override
  _CreateAgencyPageState createState() => _CreateAgencyPageState();
}

class _CreateAgencyPageState extends State<CreateAgencyPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Agency'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepContent(_currentStep),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
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
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Agency Name'),
        );
      case 1:
        return TextField(
          controller: _contactController,
          decoration: InputDecoration(labelText: 'Contact'),
        );
      case 2:
        return TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
        );
      default:
        return Container();
    }
  }

  void _submitForm() async {
    String name = _nameController.text.trim();
    String contact = _contactController.text.trim();
    String email = _emailController.text.trim();

    // Validate input
    if (name.isEmpty || contact.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Create agency object
    Agency newAgency = Agency(name: name, contact: contact, email: email);

    // Add agency to Firestore
    try {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('agencies').add({
        'name': newAgency.name,
        'contact': newAgency.contact,
        'email': newAgency.email,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agency created successfully')),
      );

      // Navigate to AgencyHomePage after creating agency
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
    }
  }
}