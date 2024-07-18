import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InviterResponsesPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  InviterResponsesPage({required this.userId});

  Future<Map<String, dynamic>> _fetchBladerName(String recipientId) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(recipientId).get();
    return userSnapshot.exists
        ? userSnapshot.data() as Map<String, dynamic>
        : {'blader_name': 'Unknown'};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inviter Responses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('invitations')
            .where('invitedBy',
                isEqualTo: userId) // Fetch invitations sent by current user
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No responses'));
          }

          final responses = snapshot.data!.docs;
          return ListView.builder(
            itemCount: responses.length,
            itemBuilder: (context, index) {
              final response = responses[index];
              final recipientId = response['recipientId'];
              final status = response['status'];

              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchBladerName(recipientId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                      subtitle: Text('Status: $status'),
                    );
                  }

                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('Unknown Blader'),
                      subtitle: Text('Status: $status'),
                    );
                  }

                  final bladerName = userSnapshot.data!['blader_name'];
                  return ListTile(
                    title: Text('Blader: $bladerName'),
                    subtitle: Text('Status: $status'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
