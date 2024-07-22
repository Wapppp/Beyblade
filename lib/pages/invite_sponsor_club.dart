import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InviteSponsorClubLeadersPage extends StatefulWidget {
  @override
  _InviteSponsorClubLeadersPageState createState() =>
      _InviteSponsorClubLeadersPageState();
}

class _InviteSponsorClubLeadersPageState
    extends State<InviteSponsorClubLeadersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentUserId;
  String? currentUserSponsorId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userSnapshot =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (userSnapshot.exists) {
        setState(() {
          currentUserId = currentUser.uid;
          currentUserSponsorId = userSnapshot.get('sponsor_id');
        });
      } else {
        print('User document does not exist');
        // Handle case where user document does not exist
      }
    } else {
      print('Current user is null');
      // Handle case where current user is null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Club Leaders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('clubs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No club leaders available'));
          }

          final clubLeaders = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'club_name': data['name'] ?? 'No Club Name',
              'leader_name': data['leader_name'] ?? '',
              'leader_id': data['leader'] ?? '',
              'clubId': doc.id,
            };
          }).toList();

          return ListView.builder(
            itemCount: clubLeaders.length,
            itemBuilder: (context, index) {
              final clubLeader = clubLeaders[index];
              return ListTile(
                title: Text(clubLeader['club_name']),
                subtitle: Text(clubLeader['leader_name']),
                trailing: IconButton(
                  icon: Icon(Icons.mail),
                  onPressed: currentUserId != null
                      ? () => _showInviteDialog(
                            clubLeader[
                                'leader_id'], // Use leader_id as recipientId
                            clubLeader['leader_name'],
                          )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showInviteDialog(String userId, String leaderName) {
    String title = '';
    String message = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Send Invitation to $leaderName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Message'),
                onChanged: (value) {
                  message = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _inviteClubLeader(userId, title, message);
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _inviteClubLeader(String userId, String title, String message) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        // Fetch current user's sponsor name
        final currentUserSnapshot =
            await _firestore.collection('users').doc(currentUserId).get();

        if (!currentUserSnapshot.exists) {
          print('Current user document not found');
          return;
        }

        final currentUserSponsorId = currentUserSnapshot.get('sponsor_id');

        // Fetch sponsor name of the current user
        final sponsorSnapshot = await _firestore
            .collection('sponsors')
            .doc(currentUserSponsorId)
            .get();

        if (!sponsorSnapshot.exists) {
          print('Sponsor document not found');
          return;
        }

        final currentUserSponsorName = sponsorSnapshot.get('sponsor_name');

        // Check if there is already an invitation sent to this club leader by this sponsor
        final existingInvitations = await _firestore
            .collection('invitations')
            .where('recipientId', isEqualTo: userId)
            .where('sponsorId', isEqualTo: currentUserSponsorId)
            .get();

        if (existingInvitations.docs.isEmpty) {
          // If no existing invitation, send a new invitation
          if (title.isNotEmpty && message.isNotEmpty) {
            await _firestore.collection('invitations').add({
              'recipientId': userId,
              'sponsorId': currentUserSponsorId,
              'sponsorName': currentUserSponsorName, // Add sponsor name here
              'sponsorEmail': currentUser.email,
              'title': title,
              'message': message,
              'createdAt': FieldValue.serverTimestamp(),
              'invitedBy': currentUserId,
              'status': 'pending',
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invitation sent')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Title and message cannot be empty')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User already invited by this sponsor')),
          );
        }
      } catch (e) {
        print('Error inviting club leader: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send invitation')),
        );
      }
    }
  }
}
