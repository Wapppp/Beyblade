import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageRankingsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Rankings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('rankings').orderBy('rank').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No rankings found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var ranking = snapshot.data!.docs[index];
              var bladerName = ranking['blader_name'] ?? 'No Name';
              var rank = ranking['rank'] ?? 'No Rank';
              var points = ranking['points'] ?? 'No Points';

              return ListTile(
                title: Text(bladerName),
                subtitle: Text('Rank: $rank | Points: $points'),
              );
            },
          );
        },
      ),
    );
  }
}