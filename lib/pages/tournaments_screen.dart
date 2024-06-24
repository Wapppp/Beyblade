import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tournament_details_screen.dart';

class TournamentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('All Tournaments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('tournaments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tournaments available'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return _buildTournamentTile(doc, context);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTournamentTile(DocumentSnapshot doc, BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('organizers').doc(doc['organizerId']).get(),
      builder: (context, organizerSnapshot) {
        if (organizerSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (organizerSnapshot.hasError) {
          return Center(child: Text('Error: ${organizerSnapshot.error}'));
        }
        if (!organizerSnapshot.hasData || !organizerSnapshot.data!.exists) {
          return Center(child: Text('Organizer not found'));
        }

        final organizerName = organizerSnapshot.data!['organizer_name'];

        return ListTile(
          title: Text(doc['name']),
          subtitle: Text('Organizer: $organizerName'),
          onTap: () {
            _navigateToDetailsScreen(doc, context);
          },
        );
      },
    );
  }

  void _navigateToDetailsScreen(
      DocumentSnapshot tournamentDoc, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TournamentDetailsScreen(tournamentDoc: tournamentDoc),
      ),
    );
  }
}
