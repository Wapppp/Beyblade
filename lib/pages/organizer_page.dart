import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_event_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tournament_details_screen.dart';
import 'organizer_profile_screen.dart';
import 'bracket_management_page.dart'; // Import the BracketManagementPage
import 'create_bracket_screen.dart'; // Import the CreateBracketScreen
import 'manage_bracket_page.dart'; // Import the BracketManagementPage
import 'tournaments_screen.dart'; // Import the TournamentsScreen

class OrganizerPage extends StatefulWidget {
  @override
  _OrganizerPageState createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Organizer Page',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber.shade600,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.amber.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/150'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Organizer Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.event, color: Colors.amber.shade600),
              title: Text(
                'Create an Event',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventScreen(
                      onEventCreated: addEvent,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: Colors.amber.shade600),
              title: Text(
                'Organizer Dashboard',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Organizer Dashboard tapped')),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.black87,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to the Organizer Page!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade600,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tournaments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No tournaments available',
                            style: TextStyle(color: Colors.white),
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

                      return DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Date',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Location',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Description',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: events
                            .map((event) => DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        event.name,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        event.date,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        event.location,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        event.description,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addEvent(TournamentEvent event) {
    FirebaseFirestore.instance.collection('tournaments').add({
      'name': event.name,
      'date': event.date,
      'location': event.location,
      'description': event.description,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tournament Event Created')),
      );
    }).catchError((error) {
      print('Error adding event: $error');
    });
  }
}

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

class CreateEventScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final Function(TournamentEvent) onEventCreated;

  CreateEventScreen({required this.onEventCreated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Tournament'),
        backgroundColor: Colors.amber.shade600,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Organize a Tournament Event',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.grey,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToTournamentsScreen,
              child: Text('View All Tournaments'),
            ),
            SizedBox(height: 20),
            _buildOrganizerTournaments(user!.uid),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizerTournaments(String organizerId) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Tournaments:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('tournaments')
                .where('organizerId', isEqualTo: organizerId)
                .snapshots(),
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

              return Expanded(
                child: ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return _buildTournamentTile(doc);
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentTile(DocumentSnapshot doc) {
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.format_list_bulleted), // Updated icon
                onPressed: () {
                  _navigateToBracketManagementPage(doc.id);
                },
              ),
              IconButton(
                icon: Icon(Icons.manage_search),
                onPressed: () {
                  _navigateToManageBracketPage(doc.id);
                },
              ),
            ],
          ),
          onTap: () {
            _navigateToDetailsScreen(doc);
          },
        );
      },
    );
  }

  void _navigateToCreateEventScreen(String organizerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          onEventCreated: (event) {
            _addEvent(event, organizerId);
          },
          organizerId: organizerId,
        ),
      ),
    );
  }

  void _addEvent(TournamentEvent event, String organizerId) async {
    try {
      await _firestore.collection('tournaments').add({
        'name': event.name,
        'date': event.dateAndTime,
        'location': event.location,
        'description': event.description,
        'organizerId': organizerId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tournament Event Created')),
      );
    } catch (error) {
      print('Error adding event: $error');
    }
  }

  void _navigateToDetailsScreen(DocumentSnapshot tournamentDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TournamentDetailsScreen(tournamentDoc: tournamentDoc),
      ),
    );
  }

  void _navigateToOrganizerProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizerProfileScreen(userId: user!.uid),
      ),
    );
  }

  void _navigateToBracketManagementPage(String tournamentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BracketManagementPage(tournamentId: tournamentId),
      ),
    );
  }

  void _navigateToManageBracketPage(String tournamentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageBracketPage(tournamentId: tournamentId),
      ),
    );
  }

  void _navigateToTournamentsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentsScreen(),
      ),
    );
  }
}
