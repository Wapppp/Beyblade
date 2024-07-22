import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManageInvitationsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Invitations'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('invitations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No invitations found'));
          }

          final invitations = snapshot.data!.docs;
          return ListView.builder(
            itemCount: invitations.length,
            itemBuilder: (context, index) {
              final invitation = invitations[index];
              String inviterName = '';
              String inviterType = '';
              String inviterEmail = '';

              final data = invitation.data() as Map<String, dynamic>;

              if (data.containsKey('agencyEmail')) {
                inviterName = data['agencyName'];
                inviterEmail = data['agencyEmail'];
                inviterType = 'Agency';
              } else if (data.containsKey('sponsorEmail')) {
                inviterName = data['sponsorName'];
                inviterEmail = data['sponsorEmail'];
                inviterType = 'Sponsor';
              } else {
                print('No valid inviter information found');
                return Container();
              }

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(
                    'Invited by: $inviterName',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Type: $inviterType\nStatus: ${data['status']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () =>
                      _showInvitationDetails(context, invitation, inviterType),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _respondToInvitation(
                            context, invitation.id, 'accepted', inviterType),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _respondToInvitation(
                            context, invitation.id, 'declined', inviterType),
                      ),
                    ],
                  ),
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
      final data = invitation.data() as Map<String, dynamic>;

      if (inviterType == 'Agency') {
        inviterId = data['agencyId'];
        inviterEmail = data['agencyEmail'];

        DocumentSnapshot agencySnapshot =
            await _firestore.collection('agencies').doc(inviterId).get();

        if (!agencySnapshot.exists) {
          print('Agency document not found');
          return;
        }

        inviterName = agencySnapshot.get('agency_name');
      } else if (inviterType == 'Sponsor') {
        inviterId = data['sponsorId'];
        inviterEmail = data['sponsorEmail'];

        DocumentSnapshot sponsorSnapshot =
            await _firestore.collection('sponsors').doc(inviterId).get();

        if (!sponsorSnapshot.exists) {
          print('Sponsor document not found');
          return;
        }

        inviterName = sponsorSnapshot.get('sponsor_name');
      } else {
        print('Invalid inviter type');
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
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
                      Text('Invitation Details',
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Text('Invited by Type:',
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Text(inviterType,
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.0),
                  Text('Invited by:',
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Text(inviterName,
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.0),
                  Text('Inviter Email:',
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Text(inviterEmail, style: TextStyle(fontSize: 18.0)),
                  SizedBox(height: 20.0),
                  Divider(height: 1.0, color: Colors.grey),
                  SizedBox(height: 20.0),
                  Text('Title:',
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Text(data['title'],
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.0),
                  Text('Message:',
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Text(data['message'], style: TextStyle(fontSize: 18.0)),
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
          SnackBar(content: Text('Failed to fetch inviter details')));
    }
  }

  Future<void> _respondToInvitation(BuildContext context, String invitationId,
      String status, String inviterType) async {
    try {
      DocumentSnapshot invitationSnapshot =
          await _firestore.collection('invitations').doc(invitationId).get();
      if (!invitationSnapshot.exists) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Invitation not found')));
        return;
      }

      String inviterId = '';
      String inviterEmail = '';
      final data = invitationSnapshot.data() as Map<String, dynamic>;

      if (inviterType == 'Agency') {
        inviterId = data['agencyId'];
        inviterEmail = data['agencyEmail'];
      } else if (inviterType == 'Sponsor') {
        inviterId = data['sponsorId'];
        inviterEmail = data['sponsorEmail'];
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
            'Your invitation has been $status by ${data['recipientId']}.',
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invitation $status')));
    } catch (e) {
      print('Error responding to invitation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to respond to invitation')));
    }
  }
}
