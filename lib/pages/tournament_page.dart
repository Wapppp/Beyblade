import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tournament_details_page.dart'; // Import TournamentDetailsPage and TournamentEvent

class TournamentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournaments'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[200], // White text color
                ),
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
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  elevation: 4,
                  color: Colors.grey[850], // Dark grey card background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    title: Text(
                      tournament.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text color
                      ),
                    ),
                    subtitle: Text(
                      _formatTimestamp(tournament.date),
                      style: TextStyle(
                        color: Colors.white70, // White70 text color
                      ),
                    ),
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
                  ),
                ),
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
