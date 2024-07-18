import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvitationsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  InvitationsPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invitations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('invitations')
            .where('recipientId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No invitations'));
          }

          final invitations = snapshot.data!.docs;
          return ListView.builder(
            itemCount: invitations.length,
            itemBuilder: (context, index) {
              final invitation = invitations[index];
              String inviterName = '';
              String inviterType = '';
              String inviterEmail = '';
              String status = invitation['status'] ?? '';
              final Map<String, dynamic>? invitationData =
                  invitation.data() as Map<String, dynamic>?;

              if (invitationData != null) {
                if (invitationData.containsKey('agencyEmail')) {
                  inviterName = invitationData['agencyName'] as String;
                  inviterEmail = invitationData['agencyEmail'] as String;
                  inviterType = 'Agency';
                } else if (invitationData.containsKey('sponsorEmail')) {
                  inviterName = invitationData['sponsorName'] as String;
                  inviterEmail = invitationData['sponsorEmail'] as String;
                  inviterType = 'Sponsor';
                } else {
                  print('No valid inviter information found');
                  return Container(); // or handle this case as per your app's logic
                }
              } else {
                print('Invitation data is null');
                return Container(); // or handle this case as per your app's logic
              }

              return ListTile(
                title: Text('Invited by: $inviterName'),
                subtitle: Text('Inviter Type: $inviterType\nStatus: $status'),
                onTap: () =>
                    _showInvitationDetails(context, invitation, inviterType),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () => _respondToInvitation(
                          context, invitation.id, 'accepted', inviterType),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => _respondToInvitation(
                          context, invitation.id, 'declined', inviterType),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showInvitationDetails(BuildContext context, DocumentSnapshot invitation,
      String inviterType) async {
    try {
      String inviterId = '';
      String inviterName = '';
      String inviterEmail = '';
      String title = invitation['title'] ?? '';
      String message = invitation['message'] ?? '';

      if (inviterType == 'Agency') {
        String agencyId = invitation['agencyId'] ?? '';

        if (agencyId.isNotEmpty) {
          DocumentSnapshot agencySnapshot =
              await _firestore.collection('agencies').doc(agencyId).get();

          if (!agencySnapshot.exists) {
            print('Agency document not found');
            return;
          }

          inviterName = agencySnapshot.get('agency_name') as String;
          inviterEmail = invitation['agencyEmail'] ?? '';
        } else {
          print('Agency invitation data incomplete or invalid');
          return;
        }
      } else if (inviterType == 'Sponsor') {
        String sponsorId = invitation['sponsorId'] ?? '';

        if (sponsorId.isNotEmpty) {
          DocumentSnapshot sponsorSnapshot =
              await _firestore.collection('sponsors').doc(sponsorId).get();

          if (!sponsorSnapshot.exists) {
            print('Sponsor document not found');
            return;
          }

          inviterName = sponsorSnapshot.get('sponsor_name') as String;
          inviterEmail = invitation['sponsorEmail'] ?? '';
        } else {
          print('Sponsor invitation data incomplete or invalid');
          return;
        }
      } else {
        print('Invalid inviter type');
        return;
      }

      // Show dialog with invitation details
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.white,
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Invitation Details',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Invited by Type:',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    inviterType,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Invited by:',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    inviterName,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Inviter Email:',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    inviterEmail,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Divider(height: 1.0, color: Colors.grey),
                  SizedBox(height: 20.0),
                  Text(
                    'Title:',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Message:',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error fetching inviter details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch inviter details')),
      );
    }
  }

  Future<void> _respondToInvitation(BuildContext context, String invitationId,
      String status, String inviterType) async {
    try {
      DocumentSnapshot invitationSnapshot =
          await _firestore.collection('invitations').doc(invitationId).get();
      if (!invitationSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation not found')),
        );
        return;
      }

      String inviterId = '';
      String inviterEmail = '';

      if (inviterType == 'Agency') {
        inviterId = invitationSnapshot['agencyId'] ?? '';
        inviterEmail = invitationSnapshot['agencyEmail'] ?? '';
      } else if (inviterType == 'Sponsor') {
        inviterId = invitationSnapshot['sponsorId'] ?? '';
        inviterEmail = invitationSnapshot['sponsorEmail'] ?? '';
      } else {
        print('Invalid inviter type');
        return;
      }

      await _firestore.collection('invitations').doc(invitationId).update({
        'status': status,
      });

      await _firestore.collection('notifications').add({
        'recipientId': inviterId,
        'title': 'Invitation Response',
        'message':
            'Your invitation has been $status by ${invitationSnapshot['recipientId']}.',
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitation $status')),
      );
    } catch (e) {
      print('Error responding to invitation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to respond to invitation')),
      );
    }
  }
}
