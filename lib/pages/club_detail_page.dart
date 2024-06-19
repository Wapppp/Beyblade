import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beyblade/pages/manage_club_page.dart';
import 'package:beyblade/pages/profile_detail_page.dart';

class ClubDetailPage extends StatelessWidget {
  final DocumentSnapshot clubSnapshot;
  final String userId;

  ClubDetailPage({required this.clubSnapshot, required this.userId});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> clubData = clubSnapshot.data() as Map<String, dynamic>;
    bool isLeader = clubData['leader'] == userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(clubData['name'] ?? 'Club Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              clubData['name'] ?? 'Club Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            FutureBuilder<DocumentSnapshot>(
              future: _fetchMemberData(clubData['leader']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Leader: Loading...');
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return Text('Leader: Unknown');
                } else {
                  var leaderData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileDetailPage(uid: clubData['leader']),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(leaderData['profile_picture'] ?? ''),
                          radius: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Leader: ${leaderData['blader_name'] ?? 'Unknown'}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            FutureBuilder<DocumentSnapshot>(
              future: _fetchMemberData(clubData['vice_captain_name']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Vice Captain: Loading...');
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return Text('Vice Captain: None');
                } else {
                  var viceCaptainData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileDetailPage(
                              uid: clubData['vice_captain_name']),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                              viceCaptainData['profile_picture'] ?? ''),
                          radius: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Vice Captain: ${viceCaptainData['blader_name'] ?? 'None'}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            Text(
              'Members:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _buildMembersList(clubData['members'], clubData['leader']),
            ),
            SizedBox(height: 16),
            if (!isLeader)
              ElevatedButton(
                onPressed: () {
                  _leaveClub(context, userId, clubSnapshot.id);
                  Navigator.pop(context);
                },
                child: Text('Leave Club'),
              ),
            if (isLeader)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _navigateToManageClubPage(context, clubSnapshot);
                    },
                    child: Text('Manage Club'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(List<dynamic>? members, String? leaderId) {
    if (members == null || leaderId == null) {
      return Center(child: Text('No members found'));
    }

    List<String> filteredMembers = members
        .where((memberId) => memberId != leaderId)
        .map((e) => e.toString())
        .toList();

    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchMembersData(filteredMembers),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No members found'));
        }
        List<DocumentSnapshot> memberDocs = snapshot.data!;
        return ListView.builder(
          itemCount: memberDocs.length,
          itemBuilder: (context, index) {
            var memberData = memberDocs[index].data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileDetailPage(uid: memberDocs[index].id),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(memberData['profile_picture'] ?? ''),
                  radius: 20,
                ),
                title: Text(memberData['blader_name'] ?? 'Unknown'),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> _fetchMembersData(
      List<String> memberIds) async {
    var memberFutures = memberIds.map(
        (uid) => FirebaseFirestore.instance.collection('users').doc(uid).get());
    return await Future.wait(memberFutures);
  }

  Future<DocumentSnapshot> _fetchMemberData(String? memberId) async {
    if (memberId == null || memberId.isEmpty) {
      // Return a dummy document with default values or handle it based on your app's logic
      return FirebaseFirestore.instance.collection('users').doc('dummy').get();
    }
    try {
      // Fetch the document snapshot corresponding to the memberId
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(memberId)
          .get();
    } catch (e) {
      // Handle errors fetching the document, if necessary
      print('Error fetching member data: $e');
      throw e; // Rethrow the error or handle it gracefully based on your app's requirements
    }
  }

  Future<void> _leaveClub(
      BuildContext context, String userId, String clubId) async {
    if (clubId.isEmpty) {
      print('Club ID is invalid!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave club: Invalid club ID')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('clubs').doc(clubId).update({
        'members': FieldValue.arrayRemove([userId])
      });
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You left the club')),
        );
      }
    } catch (e) {
      print('Error leaving club: $e');
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave club: $e')),
        );
      }
    }
  }

  void _navigateToManageClubPage(
      BuildContext context, DocumentSnapshot clubSnapshot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageClubPage(clubSnapshot: clubSnapshot),
      ),
    );
  }
}
