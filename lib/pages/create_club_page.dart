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
                  String clubName = _clubNameController.text.trim();
                  if (clubName.isNotEmpty) {
                    await FirebaseFirestore.instance.collection('clubs').add({
                      'name': clubName,
                      'leader': user.uid,
                      'members': [user.uid],
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
}
