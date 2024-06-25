import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beyblade/pages/create_club_page.dart';
import 'club_users_page.dart';

// Define the color palette for the app
class AppColors {
  static const Color primaryColor = Colors.orange;
  static const Color accentColor = Colors.amber;
  static const Color appBarColor = Colors.black;
  static const Color scaffoldBackgroundColor = Colors.grey;
  static const Color cardColor = Color.fromARGB(255, 36, 36, 36);
  static const Color textColor = Colors.white;
}

class ClubManagementPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Club Management',
          style: TextStyle(color: AppColors.textColor),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                'Club List',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ClubList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateClubPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: AppColors.primaryColor,
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

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  title: Text(
                    '${index + 1}. $name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClubUsersPage(clubId: clubId),
                      ),
                    );
                  },
                  tileColor: AppColors.cardColor,
                  leading: CircleAvatar(
                    child: Icon(Icons.group, color: Colors.white),
                    backgroundColor: AppColors.primaryColor,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
