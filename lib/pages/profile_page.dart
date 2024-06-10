
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _bladerNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    // Stream to fetch user data from Firestore
    Stream<DocumentSnapshot<Map<String, dynamic>>> userDataStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid) // Assuming you're storing user data with their UID as document ID
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: userDataStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Loading indicator while data is being fetched
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return Text('No data available'); // If no data is available
            }
            // Data is available, extract and display it
            Map<String, dynamic> userData = snapshot.data!.data()!;
            _bladerNameController.text = userData['blader_name'];

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'User Profile',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _bladerNameController,
                  decoration: InputDecoration(labelText: 'Blader Name'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'blader_name': _bladerNameController.text});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile updated successfully')),
                    );
                  },
                  child: Text('Save Changes'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bladerNameController.dispose();
    super.dispose();
  }
}

