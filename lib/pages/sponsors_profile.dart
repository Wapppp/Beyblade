import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SponsorProfilePage extends StatefulWidget {
  @override
  _SponsorProfilePageState createState() => _SponsorProfilePageState();
}

class _SponsorProfilePageState extends State<SponsorProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _sponsorNameController;
  late TextEditingController _sponsorEmailController;
  File? _image;
  String _imageUrl = '';
  bool _isLoading = false;
  String? _sponsorId; // Track sponsor_id

  @override
  void initState() {
    super.initState();
    _sponsorNameController = TextEditingController();
    _sponsorEmailController = TextEditingController();
    _loadSponsorData();
  }

  void _loadSponsorData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Query sponsors collection for documents where createdBy matches current user's UID
        QuerySnapshot querySnapshot = await _firestore
            .collection('sponsors')
            .where('createdBy', isEqualTo: user.uid)
            .get();

        // Assume only one sponsor per user for simplicity, otherwise handle accordingly
        if (querySnapshot.docs.isNotEmpty) {
          var sponsorData =
              querySnapshot.docs.first.data() as Map<String, dynamic>;
          setState(() {
            _sponsorId = querySnapshot.docs.first.id;
            _sponsorNameController.text = sponsorData['sponsor_name'] ?? '';
            _sponsorEmailController.text = sponsorData['sponsor_email'] ?? '';
            _imageUrl = sponsorData['profile_picture'] ?? '';
          });
        }
      } catch (e) {
        print('Error fetching sponsor data: $e');
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
          .child('sponsor_profile_pictures/${_auth.currentUser!.uid}');
      await ref.putFile(_image!);
      final url = await ref.getDownloadURL();

      setState(() {
        _imageUrl = url;
        _isLoading = false;
      });

      // Update Firestore with new profile picture URL
      await _firestore.collection('sponsors').doc(_sponsorId).update({
        'profile_picture': _imageUrl,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile picture updated')));
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
    try {
      await _firestore.collection('sponsors').doc(_sponsorId).update({
        'sponsor_name': _sponsorNameController.text,
        'sponsor_email': _sponsorEmailController.text,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile updated')));
    } catch (e) {
      print('Error updating sponsor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  void dispose() {
    _sponsorNameController.dispose();
    _sponsorEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sponsor Profile'),
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
                        : AssetImage('assets/default_profile.png')),
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
              controller: _sponsorNameController,
              decoration: InputDecoration(labelText: 'Sponsor Name'),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _sponsorEmailController,
              decoration: InputDecoration(labelText: 'Sponsor Email'),
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