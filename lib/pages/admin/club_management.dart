import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubManagementPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Management'),
      ),
      body: ClubList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateClubPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ClubList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('clubs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No clubs found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var club = snapshot.data!.docs[index];
            var name = club['name'] ?? 'No Name';
            var clubId = club.id; // Get the club ID

            return ListTile(
              title: Text(name),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClubUsersPage(clubId: clubId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class CreateClubPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Club'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Club Name'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('clubs').add({
                  'name': nameController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Create Club'),
            ),
          ],
        ),
      ),
    );
  }
}

class ClubUsersPage extends StatelessWidget {
  final String clubId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ClubUsersPage({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('clubId', isEqualTo: clubId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found for this club.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var user = snapshot.data!.docs[index];
              var name = user['name'] ?? 'No Name';
              var email = user['email'] ?? 'No Email';
              return ListTile(
                title: Text(name),
                subtitle: Text(email),
                // Implement other user details if needed
              );
            },
          );
        },
      ),
    );
  }
}

class EditClubPage extends StatelessWidget {
  final TextEditingController nameController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DocumentSnapshot club;

  EditClubPage({required this.club})
      : nameController = TextEditingController(text: club['name']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Club'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Club Name'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('clubs').doc(club.id).update({
                  'name': nameController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
