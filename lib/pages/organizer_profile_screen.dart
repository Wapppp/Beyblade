import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class OrganizerProfileScreen extends StatefulWidget {
  final String userId;

  const OrganizerProfileScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _OrganizerProfileScreenState createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends State<OrganizerProfileScreen> {
  final TextEditingController _organizerNameController =
      TextEditingController();
  final TextEditingController _organizerEmailController =
      TextEditingController();
  final TextEditingController _organizerDescriptionController =
      TextEditingController();

  bool isEditMode = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchOrganizerData();
  }

  Future<void> _fetchOrganizerData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> organizerSnapshot =
          await FirebaseFirestore.instance
              .collection('organizers')
              .doc(widget.userId)
              .get();

      if (organizerSnapshot.exists) {
        setState(() {
          _organizerNameController.text =
              organizerSnapshot.data()?['organizer_name'] ?? '';
          _organizerEmailController.text =
              organizerSnapshot.data()?['organizer_email'] ?? '';
          _organizerDescriptionController.text =
              organizerSnapshot.data()?['description'] ?? '';
          _imageUrl = organizerSnapshot.data()?['profile_picture'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching organizer data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEditMode) {
                try {
                  await FirebaseFirestore.instance
                      .collection('organizers')
                      .doc(widget.userId)
                      .update({
                    'organizer_name': _organizerNameController.text,
                    'organizer_email': _organizerEmailController.text,
                    'description': _organizerDescriptionController.text,
                    'profile_picture': _imageUrl,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile')),
                  );
                }
              }
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildAvatar(),
            buildProfileField(
                'Organizer Name', _organizerNameController, isEditMode),
            buildProfileField('Email', _organizerEmailController, isEditMode),
            buildDescriptionField(),
          ],
        ),
      ),
    );
  }

  Widget buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _imageUrl != null
              ? NetworkImage(_imageUrl!)
              : AssetImage('assets/default_profile.jpg') as ImageProvider,
        ),
        if (isEditMode)
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () {
                _pickImage();
              },
            ),
          ),
      ],
    );
  }

  Widget buildProfileField(
      String label, TextEditingController controller, bool isEditMode) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            isEditMode
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Enter $label',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(controller.text),
          ],
        ),
      ),
    );
  }

  Widget buildDescriptionField() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            isEditMode
                ? TextField(
                    controller: _organizerDescriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter Description',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(_organizerDescriptionController.text),
          ],
        ),
      ),
    );
  }

  void _pickImage() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isEmpty) return;
      final reader = html.FileReader();
      reader.readAsDataUrl(files[0]);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _imageUrl = reader.result as String?;
        });
      });
    });
  }

  @override
  void dispose() {
    _organizerNameController.dispose();
    _organizerEmailController.dispose();
    _organizerDescriptionController.dispose();
    super.dispose();
  }
}
