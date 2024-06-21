import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentParticipantsPage extends StatelessWidget {
  final String tournamentId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TournamentParticipantsPage({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournament Participants'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('participants')
            .where('tournament_id', isEqualTo: tournamentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No participants found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var participant = snapshot.data!.docs[index];
              var bladerName = participant['blader_name'] ?? 'No Name';
              var userId = participant['user_id'] ?? 'Unknown ID';

              return ListTile(
                leading: FutureBuilder<DocumentSnapshot>(
                  future: _fetchProfileData(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        child: Text(bladerName[0]),
                      );
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        !snapshot.data!.exists) {
                      return CircleAvatar(
                        child: Text(bladerName[0]),
                      );
                    } else {
                      var profileData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return CircleAvatar(
                        backgroundImage:
                            NetworkImage(profileData['profile_picture'] ?? ''),
                        child: Text(bladerName[0]),
                      );
                    }
                  },
                ),
                title: Text(bladerName),
                subtitle: Text('User ID: $userId'),
              );
            },
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> _fetchProfileData(String userId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
    } catch (e) {
      print('Error fetching profile data: $e');
      throw e;
    }
  }
}