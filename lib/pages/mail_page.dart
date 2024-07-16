import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MailPage extends StatefulWidget {
  @override
  _MailPageState createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> _fetchInvitations() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        return [];
      }

      List<Map<String, dynamic>> invitations = [];

      // Fetch from invitations collection
      QuerySnapshot snapshotInvitations = await _firestore
          .collection('invitations')
          .where('recipientId', isEqualTo: userId)
          .get();

      for (var doc in snapshotInvitations.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Fetch blader_name and email from users collection based on recipientId
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(data['recipientId']).get();
        String bladerName = userSnapshot['blader_name'];
        String email = userSnapshot['email'];

        invitations.add({
          'id': doc.id, // Add document ID for updating later
          'source': 'invitations',
          'agencyEmail': data['agencyEmail'],
          'agencyId': data['agencyId'],
          'createdAt': data['createdAt'],
          'recipientId': data['recipientId'],
          'agencyName': data['agencyName'],
          'invitationTitle': data['invitationTitle'],
          'invitationDescription': data['invitationDescription'],
          'invitationMessage': data['invitationMessage'],
          'bladerName': bladerName,
          'email': email,
        });
      }

      // Fetch from inviteclubs collection
      QuerySnapshot snapshotInviteClubs = await _firestore
          .collection('inviteclubs')
          .where('recipientId', isEqualTo: userId)
          .get();

      for (var doc in snapshotInviteClubs.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Fetch blader_name and email from users collection based on recipientId
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(data['recipientId']).get();
        String bladerName = userSnapshot['blader_name'];
        String email = userSnapshot['email'];

        invitations.add({
          'id': doc.id, // Add document ID for updating later
          'source': 'inviteclubs',
          'agencyEmail': data['agencyEmail'],
          'agencyId': data['agencyId'],
          'createdAt': data['createdAt'],
          'recipientId': data['recipientId'],
          'agencyName': data['agencyName'],
          'invitationTitle': data['invitationTitle'],
          'invitationDescription': data['invitationDescription'],
          'invitationMessage': data['invitationMessage'],
          'bladerName': bladerName,
          'email': email,
        });
      }

      return invitations;
    } catch (e) {
      print('Error fetching invitations: $e');
      return [];
    }
  }

  void _showInvitationDetails(Map<String, dynamic> invitation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(invitation['invitationTitle']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description:'),
              SizedBox(height: 5),
              Text(invitation['invitationDescription']),
              SizedBox(height: 20),
              Text('Message:'),
              SizedBox(height: 5),
              Text(invitation['invitationMessage']),
              SizedBox(height: 20),
              Text('Blader Name:'),
              SizedBox(height: 5),
              Text(invitation['bladerName']),
              SizedBox(height: 20),
              Text('Email:'),
              SizedBox(height: 5),
              Text(invitation['email']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () => _acceptInvitation(invitation),
              child: Text('Accept'),
            ),
            TextButton(
              onPressed: () => _declineInvitation(invitation),
              child: Text('Decline'),
            ),
          ],
        );
      },
    );
  }

  void _acceptInvitation(Map<String, dynamic> invitation) async {
    try {
      await _firestore.collection(invitation['source']).doc(invitation['id']).delete();
      _notifyAgency(invitation, 'accepted');
      // Optionally: Add logic to update user or other actions
    } catch (e) {
      print('Error accepting invitation: $e');
      // Handle error gracefully, e.g., show snackbar or alert
    }
  }

  void _declineInvitation(Map<String, dynamic> invitation) async {
    try {
      await _firestore.collection(invitation['source']).doc(invitation['id']).delete();
      _notifyAgency(invitation, 'declined');
      // Optionally: Add logic to update user or other actions
    } catch (e) {
      print('Error declining invitation: $e');
      // Handle error gracefully, e.g., show snackbar or alert
    }
  }

  void _notifyAgency(Map<String, dynamic> invitation, String status) async {
    try {
      // Example notification message to the agency
      String message = 'User ${invitation['bladerName']} has $status your invitation';

      // Replace with your logic to notify the agency, e.g., send a Firestore message
      await _firestore.collection('notifications').add({
        'recipientId': invitation['agencyId'],
        'message': message,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error notifying agency: $e');
      // Handle error gracefully, e.g., show snackbar or alert
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mail Page'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchInvitations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No invitations found'));
          }

          List<Map<String, dynamic>> invitations = snapshot.data!;

          return ListView.builder(
            itemCount: invitations.length,
            itemBuilder: (context, index) {
              var invitation = invitations[index];
              return ListTile(
                title: Text(invitation['agencyName']),
                subtitle: Text(
                    'Agency Email: ${invitation['agencyEmail']}\nRecipient ID: ${invitation['recipientId']}'),
                trailing: Text(
                  (invitation['createdAt'] as Timestamp).toDate().toString(),
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () => _showInvitationDetails(invitation),
              );
            },
          );
        },
      ),
    );
  }
}