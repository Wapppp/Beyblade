import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beyblade/pages/club_detail_page.dart';
import 'package:beyblade/pages/login_page.dart';

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
          return _buildJoinClubPage(context, snapshot.data!);
        } else {
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
              var clubSnapshot = clubs[index];
              var clubData = clubSnapshot.data() as Map<String, dynamic>;
              String clubId = clubSnapshot.id;
              List<dynamic> members = clubData['members'] ?? [];
              bool isMember = members.contains(user.uid);

              return ListTile(
                title: Text(clubData['name'] ?? 'Club Name Missing'),
                subtitle:
                    Text('Leader: ${clubData['leader_name'] ?? 'Unknown'}'),
                onTap: isMember
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClubDetailPage(
                              clubSnapshot: clubSnapshot,
                              userId: user.uid,
                            ),
                          ),
                        );
                      }
                    : null,
                trailing: ElevatedButton(
                  onPressed: () {
                    if (isMember) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubDetailPage(
                            clubSnapshot: clubSnapshot,
                            userId: user.uid,
                          ),
                        ),
                      );
                    } else {
                      _joinClub(context, user.uid, clubId);
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

  Future<void> _joinClub(
      BuildContext context, String userId, String clubId) async {
    await FirebaseFirestore.instance.collection('clubs').doc(clubId).update({
      'members': FieldValue.arrayUnion([userId])
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joined club successfully')),
    );
  }
}
