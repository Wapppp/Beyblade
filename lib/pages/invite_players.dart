import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvitePlayersPage extends StatefulWidget {
  @override
  _InvitePlayersPageState createState() => _InvitePlayersPageState();
}

class _InvitePlayersPageState extends State<InvitePlayersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentUserId;
  String? currentUserAgencyId;

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
          currentUserAgencyId = userSnapshot.get('agency_id');
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
        title: Text('Invite Players'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users available'));
          }

          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['blader_name']),
                subtitle: Text(user['email']),
                trailing: IconButton(
                  icon: Icon(Icons.mail),
                  onPressed: currentUserId != null
                      ? () => _showInviteDialog(user.id, user['blader_name'])
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showInviteDialog(String userId, String bladerName) {
    String title = '';
    String message = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Send Invitation to $bladerName'),
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
                _inviteUser(userId, title, message);
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _inviteUser(String userId, String title, String message) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        // Fetch current user's agency ID
        final userSnapshot =
            await _firestore.collection('users').doc(currentUserId).get();

        if (userSnapshot.exists) {
          final currentUserAgencyId = userSnapshot.get('agency_id');

          // Fetch agency document using created_by field
          final agencySnapshot = await _firestore
              .collection('agencies')
              .doc(currentUserAgencyId)
              .get();

          if (agencySnapshot.exists) {
            final currentUserAgencyName = agencySnapshot.get('agency_name');

            // Check if there is already an invitation sent to this user by this agency
            final invitationExists = await _firestore
                .collection('invitations')
                .where('agencyId', isEqualTo: currentUserAgencyId)
                .where('recipientId', isEqualTo: userId)
                .get();

            if (invitationExists.docs.isEmpty) {
              // If no existing invitation, send a new invitation
              await _firestore.collection('invitations').add({
                'agencyId': currentUserAgencyId,
                'agencyName': currentUserAgencyName,
                'recipientId': userId,
                'createdAt': Timestamp.now(),
                'agencyEmail': currentUser.email,
                'invitedBy': currentUserId,
                'status': 'pending', // Initial status is pending
                'title': title,
                'message': message,
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invitation sent')),
              );
            } else {
              // If invitation already exists, show a message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User already invited by this agency')),
              );
            }
          } else {
            // Handle case where agency document is not found
            print('Agency document does not exist');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Failed to send invitation. Agency not found.')),
            );
          }
        } else {
          // Handle case where user document does not exist
          print('User document does not exist');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to send invitation. User not found.')),
          );
        }
      } catch (e) {
        print('Error inviting user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send invitation')),
        );
      }
    }
  }
}
