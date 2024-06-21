import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'tournament_participants_page.dart'; // Import the new file

class TournamentsManagePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tournaments'),
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
            return Center(child: Text('No tournaments found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var tournament = snapshot.data!.docs[index];
              var name = tournament['name'] ?? 'No Name';
              var date = (tournament['date'] as Timestamp).toDate();
              var location = tournament['location'] ?? 'No Location';
              var description = tournament['description'] ?? 'No Description';
              var organizerId = tournament['organizerId'] ?? 'Unknown Organizer';

              return ListTile(
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${DateFormat.yMMMMd().add_jm().format(date)}'),
                    Text('Location: $location'),
                    Text('Description: $description'),
                    Text('Organizer ID: $organizerId'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TournamentParticipantsPage(tournamentId: tournament.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement navigation to create new tournament page if needed
        },
        child: Icon(Icons.add),
      ),
    );
  }
}