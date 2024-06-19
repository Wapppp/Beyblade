import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectMemberPage extends StatelessWidget {
  final void Function(String?) onSelectMember;
  final String title;
  final String clubId;

  SelectMemberPage({
    required this.onSelectMember,
    required this.title,
    required this.clubId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('clubs')
            .doc(clubId)
            .collection('members')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<String> members =
              snapshot.data!.docs.map((doc) => doc.id).toList();

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              String memberId = members[index];
              return ListTile(
                title: Text(memberId),
                onTap: () {
                  onSelectMember(memberId); // Return selected memberId
                  Navigator.pop(context); // Close SelectMemberPage
                },
              );
            },
          );
        },
      ),
    );
  }
}
