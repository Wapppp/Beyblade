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
<<<<<<< HEAD
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('tournaments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No tournaments available',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final events = snapshot.data!.docs.map((doc) {
            return TournamentEvent(
              name: doc['name'],
              date: doc['date'],
              location: doc['location'],
              description: doc['description'],
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Date: ${event.date}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Location: ${event.location}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        event.description,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Replace with your join logic
                            sl<NavigationService>()
                                .navigateTo('/join_tournament');
                          },
                          child: Text('Join now'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
=======
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Tournaments Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sl<NavigationService>().navigateTo(
                    '/profile'); // Example navigation using NavigationService
              },
              child: Text('Go to Profile'),
            ),
          ],
        ),
>>>>>>> e05f89175013079da06c6d93b90f782689a0e6b1
      ),
    );
  }
}
<<<<<<< HEAD

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
=======
>>>>>>> e05f89175013079da06c6d93b90f782689a0e6b1
