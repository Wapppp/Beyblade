import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinClubPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join a Club'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No clubs available'));
          }

          List<QueryDocumentSnapshot> clubs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              var clubData = clubs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(clubData['name']),
                subtitle: Text('Leader: ${clubData['leader']}'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('clubs')
                          .doc(clubs[index].id)
                          .update({
                        'members': FieldValue.arrayUnion([user.uid]),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Joined ${clubData['name']}')),
                      );
                    }
                  },
                  child: Text('Join'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
