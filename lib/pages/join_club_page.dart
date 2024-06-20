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
          return _checkOrganizerAndBuildPage(context, snapshot.data!);
        } else {
          return LoginPage();
        }
      },
    );
  }

  Widget _checkOrganizerAndBuildPage(BuildContext context, User user) {
    return FutureBuilder<bool>(
      future: _isUserOrganizer(user.uid),
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

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == true) {
          // Handle error or user is an organizer
          return Scaffold(
            appBar: AppBar(
              title: Text('Join a Club'),
            ),
            body: Center(
              child: Text('Organizers cannot join or view clubs.'),
            ),
          );
        }

        // User is not an organizer, build the join club page
        return _buildJoinClubPage(context, user);
      },
    );
  }

  Future<bool> _isUserOrganizer(String userId) async {
    try {
      var docSnapshot = await FirebaseFirestore.instance
          .collection('organizers')
          .doc(userId)
          .get();

      return docSnapshot.exists;
    } catch (e) {
      print('Error checking organizer status: $e');
      return false; // Return false on error or if not an organizer
    }
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClubDetailPage(
                        clubSnapshot: clubSnapshot,
                        userId: user.uid,
                      ),
                    ),
                  );
                },
                trailing: ElevatedButton(
                  onPressed: isMember
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
                      : null, // Disable button for non-members
                  child: Text(isMember ? 'View' : 'Join'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
