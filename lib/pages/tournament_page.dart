import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/injection_container.dart';
import 'data/navigation_service.dart';

class TournamentEvent {
  final String name;
  final String date;
  final String location;
  final String description;

  TournamentEvent({
    required this.name,
    required this.date,
    required this.location,
    required this.description,
  });
}

class TournamentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournaments'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildTournamentsList(),
      ),
    );
  }

  Widget _buildTournamentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tournaments').snapshots(),
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
          return TournamentEvent(
            name: doc['name'],
            date: doc['date'],
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
              subtitle: Text(tournament.date),
              onTap: () {
                // Handle tapping on a tournament, e.g., navigate to details
                print('Tournament ${tournament.name} tapped');
              },
            );
          },
        );
      },
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeybladeX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TournamentsPage(),
    );
  }
}
