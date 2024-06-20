import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_event_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tournament_details_screen.dart';
import 'organizer_profile_screen.dart';

class OrganizerPage extends StatefulWidget {
  @override
  _OrganizerPageState createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer Page'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (user != null) {
                _navigateToCreateEventScreen(user!.uid);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              _navigateToOrganizerProfile();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the Organizer Page!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildOrganizerTournaments(user!.uid),
            SizedBox(height: 20),
            _buildAllTournaments(),
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

  Widget _buildAllTournaments() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Tournaments:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
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
}
