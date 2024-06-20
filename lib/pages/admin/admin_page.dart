import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_management_page.dart'; // Import the new file

class AdminPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(_auth.currentUser?.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Text('Access Denied'),
            ),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        if (userData['role'] != 'admin') {
          return Scaffold(
            body: Center(
              child: Text('Access Denied'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Admin Panel'),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    'Admin Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Dashboard', style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Manage Users', style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserManagementPage()));
                  },
                ),
                ListTile(
                  title: Text('Manage Content', style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContentManagementPage()));
                  },
                ),
                ListTile(
                  title: Text('Manage Tournaments',
                      style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TournamentManagementPage()));
                  },
                ),
                ListTile(
                  title: Text('Manage Clubs', style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClubManagementPage()));
                  },
                ),
              ],
            ),
          ),
          body: Container(
            color: Colors.grey[900], // Dark background color
            child: Center(
              child: Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Placeholder pages for different admin functionalities

class ContentManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Content Management'),
      ),
      body: Center(
        child: Text('Content Management Content Here'),
      ),
    );
  }
}

class TournamentManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournament Management'),
      ),
      body: Center(
        child: Text('Tournament Management Content Here'),
      ),
    );
  }
}

class ClubManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Management'),
      ),
      body: Center(
        child: Text('Club Management Content Here'),
      ),
    );
  }
}
