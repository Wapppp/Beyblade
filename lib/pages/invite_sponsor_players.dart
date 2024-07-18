import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InviteSponsorPlayersPage extends StatefulWidget {
  @override
  _InviteSponsorPlayersPageState createState() =>
      _InviteSponsorPlayersPageState();
}

class _InviteSponsorPlayersPageState extends State<InviteSponsorPlayersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentUserId;
  String? currentUserSponsorId;
  String? currentUserEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final userSnapshot =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (userSnapshot.exists) {
          final userData = userSnapshot.data();
          if (userData != null) {
            setState(() {
              currentUserId = currentUser.uid;
              currentUserSponsorId = userData['sponsor_id'] ?? '';
              currentUserEmail = currentUser.email;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Sponsor Players'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
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
                    final userData = user.data() as Map<String, dynamic>;
                    final bladerName = userData['blader_name'] ?? 'Unknown';
                    final email = userData['email'] ?? 'No email';

                    return ListTile(
                      title: Text(bladerName),
                      subtitle: Text(email),
                      trailing: IconButton(
                        icon: Icon(Icons.mail),
                        onPressed: currentUserId != null
                            ? () =>
                                _showInviteDialog(user.id, bladerName, email)
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showInviteDialog(String userId, String bladerName, String userEmail) {
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
                  setState(() {
                    title = value;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Message'),
                onChanged: (value) {
                  setState(() {
                    message = value;
                  });
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
                _inviteUser(userId, bladerName, userEmail, title, message);
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _inviteUser(String userId, String bladerName, String userEmail,
      String title, String message) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userSnapshot =
            await _firestore.collection('users').doc(currentUserId).get();

        if (userSnapshot.exists) {
          final currentUserSponsorId = userSnapshot.get('sponsor_id');

          final sponsorSnapshot = await _firestore
              .collection('sponsors')
              .doc(currentUserSponsorId)
              .get();

          if (sponsorSnapshot.exists) {
            final currentUserSponsorName = sponsorSnapshot.get('sponsor_name');

            final invitationExists = await _firestore
                .collection('invitations')
                .where('sponsorId', isEqualTo: currentUserSponsorId)
                .where('recipientId', isEqualTo: userId)
                .get();

            if (invitationExists.docs.isEmpty) {
              await _firestore.collection('invitations').add({
                'sponsorId': currentUserSponsorId,
                'sponsorName': currentUserSponsorName,
                'recipientId': userId,
                'createdAt': Timestamp.now(),
                'sponsorEmail': currentUserEmail,
                'invitedBy': currentUserId,
                'status': 'pending',
                'title': title,
                'message': message,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invitation sent')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User already invited by this sponsor')),
              );
            }
          } else {
            print('Sponsor document does not exist');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Failed to send invitation. Sponsor not found.')),
            );
          }
        } else {
          print('User document does not exist');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to send invitation. User not found.')),
          );
        }
      } else {
        print('Current user is null');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to send invitation. User not logged in.')),
        );
      }
    } catch (e) {
      print('Error inviting user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send invitation: $e')),
      );
    }
  }
}
