import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _bladerNameController = TextEditingController();

  bool isEditMode = false;
  String? _imageUrl;
  List<Map<String, dynamic>> _clubs = [];

  final picker = html.FileUploadInputElement();

  @override
  void initState() {
    super.initState();
    _fetchUserClubs();
  }

  Future<void> _fetchUserClubs() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    // Fetch clubs where the user is a member
    QuerySnapshot<Map<String, dynamic>> clubsSnapshot = await FirebaseFirestore
        .instance
        .collection('clubs')
        .where('members', arrayContains: user.uid)
        .get();

    List<Map<String, dynamic>> clubs =
        clubsSnapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      _clubs = clubs;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return LoginPage();
    }

    Stream<DocumentSnapshot<Map<String, dynamic>>> userDataStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEditMode) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({
                  'first_name': _firstNameController.text,
                  'middle_name': _middleNameController.text,
                  'last_name': _lastNameController.text,
                  'age': _ageController.text,
                  'birthdate': _birthdateController.text,
                  'email': _emailController.text,
                  'contact_no': _contactNoController.text,
                  'blader_name': _bladerNameController.text,
                  'profile_picture': _imageUrl,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile updated successfully')),
                );
              }
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userDataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No data available'));
          }

          Map<String, dynamic> userData = snapshot.data!.data()!;

          if (!isEditMode) {
            _firstNameController.text = userData['first_name'] ?? '';
            _middleNameController.text = userData['middle_name'] ?? '';
            _lastNameController.text = userData['last_name'] ?? '';
            _ageController.text = userData['age'] ?? '';
            _birthdateController.text = userData['birthdate'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _contactNoController.text = userData['contact_no'] ?? '';
            _bladerNameController.text = userData['blader_name'] ?? '';
            _imageUrl = userData['profile_picture'] ?? '';
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageUrl != null
                          ? NetworkImage(_imageUrl!)
                          : AssetImage('assets/default_profile.jpg'),
                    ),
                    isEditMode
                        ? Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.camera_alt),
                              onPressed: () {
                                _pickImage();
                              },
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                SizedBox(height: 20),
                buildProfileField('First Name', _firstNameController,
                    isEditMode, userData['first_name']),
                buildProfileField('Middle Name (Optional)',
                    _middleNameController, isEditMode, userData['middle_name']),
                buildProfileField('Last Name', _lastNameController, isEditMode,
                    userData['last_name']),
                buildProfileField(
                    'Age', _ageController, isEditMode, userData['age']),
                buildDateField('Birthdate', _birthdateController, isEditMode,
                    userData['birthdate']),
                buildProfileField(
                    'Email', _emailController, isEditMode, userData['email']),
                buildProfileField('Contact No.', _contactNoController,
                    isEditMode, userData['contact_no']),
                buildProfileField('Blader Name', _bladerNameController,
                    isEditMode, userData['blader_name']),
                SizedBox(height: 20),
                Text(
                  'Clubs Joined',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (_clubs.isNotEmpty)
                  ..._clubs.map((club) => Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text(club['name'] ?? 'Unknown Club'),
                          subtitle:
                              Text('Leader: ${club['leader'] ?? 'Unknown'}'),
                        ),
                      )),
                if (_clubs.isEmpty) Text('No clubs joined yet.'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/join_club');
                  },
                  child: Text('Join a Club'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create_club');
                  },
                  child: Text('Create a Club'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildProfileField(String label, TextEditingController controller,
      bool isEditMode, String? value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(label),
        subtitle: isEditMode
            ? TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter $label',
                ),
              )
            : Text(value ?? ''),
      ),
    );
  }

  Widget buildDateField(String label, TextEditingController controller,
      bool isEditMode, String? value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(label),
        subtitle: isEditMode
            ? TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter $label',
                ),
                readOnly: true,
                onTap: () async {
                  html.InputElement dateInput = html.InputElement()
                    ..type = 'date'
                    ..value = controller.text;
                  dateInput.click();
                  dateInput.onChange.listen((e) {
                    setState(() {
                      controller.text = DateFormat('yyyy-MM-dd')
                          .format(dateInput.valueAsDate!);
                    });
                  });
                },
              )
            : Text(value ?? ''),
      ),
    );
  }

  void _pickImage() {
    picker.accept = 'image/*';
    picker.click();
    picker.onChange.listen((e) {
      if (picker.files!.isNotEmpty) {
        html.FileReader reader = html.FileReader();
        reader.readAsDataUrl(picker.files![0]);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _imageUrl = reader.result as String?;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _birthdateController.dispose();
    _emailController.dispose();
    _contactNoController.dispose();
    _bladerNameController.dispose();
    super.dispose();
  }
}
