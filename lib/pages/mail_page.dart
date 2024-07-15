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

      QuerySnapshot snapshot = await _firestore
          .collection('invitations')
          .where('recipientId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> invitations = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        invitations.add({
          'agencyEmail': data['agencyEmail'],
          'agencyId': data['agencyId'],
          'createdAt': data['createdAt'],
          'recipientId': data['recipientId'],
          'agencyName': data['agencyName'],
          'invitationTitle': data['invitationTitle'],
          'invitationDescription': data['invitationDescription'],
          'invitationMessage': data['invitationMessage'],
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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
