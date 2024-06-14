import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beyblade/pages/club_detail_page.dart'; // Adjust the import as per your project structure
import 'package:beyblade/pages/login_page.dart'; // Import your login page

class JoinClubPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Join a Club'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is authenticated, show the join club page
          return _buildJoinClubPage(context, snapshot.data!);
        } else {
          // User is not authenticated, redirect to login page
          return LoginPage();
        }
      },
    );
  }

  Widget _buildJoinClubPage(BuildContext context, User user) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join a Club'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No clubs available'));
          }

          List<QueryDocumentSnapshot> clubs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              var clubData = clubs[index].data() as Map<String, dynamic>;
              bool isMember =
                  (clubData['members'] as List<dynamic>).contains(user.uid);

              return ListTile(
                title: Text(clubData['name']),
                subtitle: FutureBuilder<String>(
                  future: _fetchBladerName(clubData['leader']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text('Leader: Unknown');
                    }
                    return Text('Leader: ${snapshot.data}');
                  },
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    if (isMember) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubDetailPage(
                            clubData: clubData,
                            userId: user.uid,
                          ),
                        ),
                      );
                    } else {
                      _joinClub(user.uid, clubs[index].id);
                    }
                  },
                  child: Text(isMember ? 'View' : 'Join'),
                ),
              );
            },
          );
        },
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

  Future<void> _joinClub(String userId, String clubId) async {
    await FirebaseFirestore.instance.collection('clubs').doc(clubId).update({
      'members': FieldValue.arrayUnion([userId])
    });
  }
}
