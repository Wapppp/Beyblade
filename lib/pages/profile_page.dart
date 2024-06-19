import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';
import 'package:country_code_picker/country_code_picker.dart';

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
  final TextEditingController _nationalityController = TextEditingController();

  bool isEditMode = false;
  String? _imageUrl;
  List<Map<String, dynamic>> _clubs = [];

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

    List<Map<String, dynamic>> clubs = [];

    for (var doc in clubsSnapshot.docs) {
      Map<String, dynamic> clubData = doc.data();
      // Fetch the blader name of the leader
      if (clubData['leader'] != null) {
        DocumentSnapshot<Map<String, dynamic>> leaderSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(clubData['leader'])
                .get();
        if (leaderSnapshot.exists) {
          clubData['leaderBladerName'] =
              leaderSnapshot.data()?['blader_name'] ?? 'Unknown';
        } else {
          clubData['leaderBladerName'] = 'Unknown';
        }
      }
      clubs.add(clubData);
    }

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
                  'nationality': _nationalityController.text,
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
            _nationalityController.text = userData['nationality'] ?? '';
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildAvatar(),
                buildProfileField('Blader Name', _bladerNameController,
                    isEditMode, userData['blader_name']),
                buildProfileField('First Name', _firstNameController,
                    isEditMode, userData['first_name']),
                buildProfileField('Middle Name', _middleNameController,
                    isEditMode, userData['middle_name']),
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
                buildNationalityField(),
                SizedBox(height: 20),
                Text(
                  'Clubs Joined',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (_clubs.isNotEmpty)
                  ..._clubs.map((club) => buildClubCard(club)),
                if (_clubs.isEmpty) Text('No clubs joined yet.'),
                SizedBox(height: 20),
                buildActionButton(
                  text: 'Join a Club',
                  onPressed: () {
                    Navigator.pushNamed(context, '/join_club');
                  },
                ),
                buildActionButton(
                  text: 'Create a Club',
                  onPressed: () {
                    Navigator.pushNamed(context, '/create_club');
                  },
                ),
              ],
            ),
          );
        },
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

  Widget buildProfileField(String label, TextEditingController controller,
      bool isEditMode, String? value) {
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
                : Text(value ?? ''),
          ],
        ),
      ),
    );
  }

  Widget buildDateField(String label, TextEditingController controller,
      bool isEditMode, String? value) {
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
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: controller.text.isNotEmpty
                            ? DateTime.parse(controller.text)
                            : DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          controller.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                    },
                  )
                : Text(value ?? ''),
          ],
        ),
      ),
    );
  }

  Widget buildNationalityField() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nationality',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            isEditMode
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CountryCodePicker(
                          onChanged: (country) {
                            _nationalityController.text = country.code!;
                          },
                          initialSelection: 'US',
                          showCountryOnly: true,
                          alignLeft: false,
                          textStyle:
                              TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _nationalityController,
                          decoration: InputDecoration(
                            hintText: 'Select Nationality',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Image.asset(
                        'packages/country_code_picker/flags/${_nationalityController.text.toLowerCase()}.png',
                        width: 30,
                        height: 30,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Text('Flag not found');
                        },
                      ),
                      SizedBox(width: 10),
                      Text(_nationalityController.text),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildClubCard(Map<String, dynamic> club) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(club['name'] ?? 'Unknown Club',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Leader: ${club['leaderBladerName'] ?? 'Unknown'}'),
        trailing: isEditMode
            ? IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _leaveClub(club['id']),
              )
            : null,
        onTap: () {
          // Navigate to the club details page or perform other actions
        },
      ),
    );
  }

  Widget buildActionButton(
      {required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _pickImage() {
    html.FileUploadInputElement picker = html.FileUploadInputElement()
      ..accept = 'image/*';
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

  Future<void> _leaveClub(String clubId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('clubs').doc(clubId).update({
        'members': FieldValue.arrayRemove([user.uid]),
      });
      setState(() {
        _clubs.removeWhere((club) => club['id'] == clubId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have left the club')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave club: $e')),
      );
    }
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
    _nationalityController.dispose();
    super.dispose();
  }
}
