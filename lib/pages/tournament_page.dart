import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tournament_details_page.dart'; // Import TournamentDetailsPage and TournamentEvent

class TournamentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournaments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .orderBy('date')
            .limit(20) // Limiting to 20 tournaments
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No tournaments available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final tournaments = snapshot.data!.docs.map((doc) {
            Timestamp dateTimestamp =
                doc['date']; // Retrieve Timestamp from Firestore
            return TournamentEvent(
              id: doc.id, // Use document ID as tournament ID
              name: doc['name'],
              date: dateTimestamp, // Pass Timestamp as date
              location: doc['location'],
              description: doc['description'],
            );
          }).toList();

          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              return ListTile(
                title: Text(tournament.name),
                subtitle:
                    Text(_formatTimestamp(tournament.date)), // Format Timestamp
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TournamentDetailsPage(
                        tournament: tournament, // Pass tournament object
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    // Customize formatting as needed (e.g., 'yyyy-MM-dd HH:mm')
  }
}
