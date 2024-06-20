import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('clubs').doc(clubId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Club not found.'));
          }

          var clubData = snapshot.data!.data() as Map<String, dynamic>;
          var clubName = clubData['name'] ?? 'Unnamed Club';
          var leaderId = clubData['leader'] ?? '';
          var leaderName = clubData['leader_name'] ?? 'Unknown';

          var membersIds = List<String>.from(clubData['members'] ?? []);
          var membersQuery = _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: membersIds);

          return FutureBuilder<QuerySnapshot>(
            future: membersQuery.get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                return Center(child: Text('Error: ${userSnapshot.error}'));
              }

              var membersList = userSnapshot.data!.docs;

              return ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  ListTile(
                    title: Text('Club: $clubName'),
                    dense: true,
                  ),
                  ListTile(
                    title: Text('Leader'),
                    subtitle: Text(leaderName),
                  ),
                  ListTile(
                    title: Text('Members'),
                    subtitle: membersList.isEmpty
                        ? Text('No members found.')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: membersList.map((member) {
                              var memberName =
                                  member['name'] ?? 'Unnamed Member';
                              return Text(memberName);
                            }).toList(),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
