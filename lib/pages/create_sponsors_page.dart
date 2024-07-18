import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sponsors_home_page.dart';

class CreateSponsorsPage extends StatefulWidget {
  @override
  _CreateSponsorsPageState createState() => _CreateSponsorsPageState();
}

class _CreateSponsorsPageState extends State<CreateSponsorsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false; // Flag to prevent multiple submissions

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Create Sponsor',
        style: TextStyle(color: Colors.orange),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(
            controller: _nameController,
            labelText: 'Sponsor Name',
          ),
          SizedBox(height: 20),
          _buildTextField(
            controller: _emailController,
            labelText: 'Sponsor Email',
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            onPressed: _isSubmitting ? null : _submitForm,
            child: Text('Create Sponsor'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String labelText}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[400]),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  void _submitForm() async {
    print('Submitting sponsor creation form...');

    String sponsorName = _nameController.text.trim();
    String sponsorEmail = _emailController.text.trim();

    // Validate input
    if (sponsorName.isEmpty || sponsorEmail.isEmpty) {
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

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Add sponsor to Firestore with createdBy field and sponsor_id
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('sponsors').add({
          'sponsor_name': sponsorName,
          'sponsor_email': sponsorEmail,
          'createdBy': user.uid, // Set createdBy to current user's ID
          'sponsor_id': '', // Placeholder for sponsor_id
        });

        // Update sponsor_id with document ID (as string)
        await docRef.update({
          'sponsor_id': docRef.id,
        });

        // Update user document with sponsor_id
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'sponsor_id': docRef.id, // Set sponsor_id as string directly
        });

        print('Sponsor added to Firestore: ${docRef.id}');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sponsor created successfully')),
        );

        // Close dialog after creating sponsor
        Navigator.pop(context);

        // Navigate to SponsorsHomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SponsorHomePage()),
        );
      }
    } catch (e) {
      // Handle Firestore error
      print('Error creating sponsor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create sponsor')),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // Reset submission flag
      });
    }
  }

  void showCreateSponsorsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateSponsorsPage();
      },
    );
  }
}
