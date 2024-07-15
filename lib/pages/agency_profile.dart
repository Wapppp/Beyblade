import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AgencyProfilePage extends StatefulWidget {
  @override
  _AgencyProfilePageState createState() => _AgencyProfilePageState();
}

class _AgencyProfilePageState extends State<AgencyProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _agencyNameController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  File? _image;
  String _imageUrl = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _agencyNameController = TextEditingController();
    _contactController = TextEditingController();
    _emailController = TextEditingController();
    _loadAgencyData();
  }

  void _loadAgencyData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (userSnapshot.exists) {
          final userData = userSnapshot.data() as Map<String, dynamic>;
          final agencyId = userData['agency_id'];

          final agencySnapshot =
              await _firestore.collection('agencies').doc(agencyId).get();
          if (agencySnapshot.exists) {
            final agencyData = agencySnapshot.data() as Map<String, dynamic>;
            setState(() {
              _agencyNameController.text = agencyData['agency_name'] ?? '';
              _contactController.text = agencyData['contact'] ?? '';
              _emailController.text = agencyData['agency_email'] ?? '';
              _imageUrl = agencyData['profile_picture'] ??
                  ''; // Default to empty string if null
            });
          }
        }
      } catch (e) {
        print('Error fetching agency data: $e');
        // Handle error if necessary
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('agency_profile_pictures/${_auth.currentUser!.uid}');
      await ref.putFile(_image!);
      final url = await ref.getDownloadURL();

      setState(() {
        _imageUrl = url;
        _isLoading = false;
      });

      // Update Firestore with new profile picture URL
      final userSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final agencyId = userData['agency_id'];

        await _firestore.collection('agencies').doc(agencyId).update({
          'profile_picture': _imageUrl,
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Profile picture updated')));
      }
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture')));
    }
  }

  Future<void> _saveChanges() async {
    final userSnapshot =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    if (userSnapshot.exists) {
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final agencyId = userData['agency_id'];

      await _firestore.collection('agencies').doc(agencyId).update({
        'agency_name': _agencyNameController.text,
        'contact': _contactController.text,
        'agency_email': _emailController.text,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile updated')));
    }
  }

  @override
  void dispose() {
    _agencyNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agency Profile'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (_imageUrl.isNotEmpty
                        ? NetworkImage(_imageUrl)
                        : AssetImage(
                            'assets/default_profile.png')), // Use default image asset if no image is set
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Change Profile Picture'),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _agencyNameController,
              decoration: InputDecoration(labelText: 'Agency Name'),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contact'),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
