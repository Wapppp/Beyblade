import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateClubPage extends StatelessWidget {
  final TextEditingController _clubNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Club'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _clubNameController,
              decoration: InputDecoration(labelText: 'Club Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await user.reload(); // Refresh user data after reload

                  String clubName = _clubNameController.text.trim();
                  if (clubName.isNotEmpty) {
                    String leaderName = await _fetchBladerName(user.uid);

                    DocumentReference clubRef = await FirebaseFirestore.instance
                        .collection('clubs')
                        .add({
                      'name': clubName,
                      'leader': user.uid,
                      'leader_name': leaderName,
                      'vice_captain': null,
                      'vice_captain_name': null,
                      'members': [],
                    });

                    await clubRef.update({
                      'members': FieldValue.arrayUnion([user.uid]),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Club created successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a club name')),
                    );
                  }
                }
              },
              child: Text('Create Club'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _fetchBladerName(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    return userSnapshot.exists
        ? userSnapshot.data()!['blader_name'] ?? 'Unknown'
        : 'Unknown';
  }
}
