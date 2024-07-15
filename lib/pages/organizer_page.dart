import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_colors.dart'; // Import your AppColors class
import 'create_event_screen.dart';
import 'tournament_details_screen.dart';
import 'organizer_profile_screen.dart';
import 'bracket_management_page.dart';
import 'create_bracket_screen.dart';
import 'manage_bracket_page.dart';
import 'tournaments_screen.dart';

class OrganizerPage extends StatefulWidget {
  @override
  _OrganizerPageState createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
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
            onPressed: _signOut,
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
            onPressed: _navigateToOrganizerProfile,
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.appBarColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
            ElevatedButton(
              onPressed: _navigateToTournamentsScreen,
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(AppColors.primaryColor),
              ),
              child: Text('View All Tournaments'),
            ),
            SizedBox(height: 20),
            if (user != null) _buildOrganizerTournaments(user!.uid),
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
    return ListTile(
      title: Text(doc['name']),
      subtitle: Text('Organizer: ${doc['organizerName']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.format_list_bulleted),
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

  void _navigateToCreateEventScreen(String organizerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(),
      ),
    );
  }

  void _navigateToOrganizerProfile() {
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrganizerProfileScreen(userId: user!.uid),
        ),
      );
    }
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
