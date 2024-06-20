import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/injection_container.dart'; // Import dependency injection container
import 'data/navigation_service.dart'; // Import navigation service

class TournamentEvent {
  final String id;
  final String name;
  final Timestamp date;
  final String location;
  final String description;

  TournamentEvent({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
  });
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  User? _user;
  String _bladerName = '';
  String _profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        setState(() {
          _user = user;
          _bladerName =
              userData.get('blader_name') ?? user.displayName ?? 'Guest';
          _profilePictureUrl =
              userData.get('profile_picture') ?? user.photoURL ?? '';
        });
      } else {
        print('User data not found for uid: ${user.uid}');
      }
    } else {
      setState(() {
        _user = null;
        _bladerName = 'Guest';
        _profilePictureUrl = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('BeybladeX'),
        actions: _buildAppBarActions(),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Welcome to the Beyblade Community!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: _buildTournamentsCard(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          _buildBottomNavigationBarItem(Icons.home, 'Home'),
          _buildBottomNavigationBarItem(Icons.sports_esports, 'Tournaments'),
          _buildBottomNavigationBarItem(Icons.format_list_numbered, 'Rankings'),
          _buildBottomNavigationBarItem(Icons.people, 'Club'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _handleNavigation,
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_user != null) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: _profilePictureUrl.isNotEmpty
                ? NetworkImage(_profilePictureUrl)
                : AssetImage(
                    'assets/images/default_profile.png'), // Placeholder image
          ),
        ),
        SizedBox(width: 8),
        Text(
          _bladerName,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: Icon(Icons.arrow_drop_down),
          onSelected: (value) {
            if (value == 'profile') {
              _navigateToProfile();
            } else if (value == 'logout') {
              _signOut();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('My Profile'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
              ),
            ),
          ],
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.login),
          onPressed: () {
            sl<NavigationService>().navigateTo('/login');
          },
        ),
        IconButton(
          icon: Icon(Icons.app_registration),
          onPressed: () {
            sl<NavigationService>().navigateTo('/register');
          },
        ),
      ];
    }
  }

  void _navigateToProfile() {
    sl<NavigationService>().navigateTo('/profile');
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        sl<NavigationService>().navigateTo('/home');
        break;
      case 1:
        sl<NavigationService>().navigateTo('/tournaments');
        break;
      case 2:
        sl<NavigationService>().navigateTo('/rankings');
        break;
      case 3:
        sl<NavigationService>().navigateTo('/club');
        break;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      setState(() {
        _user = null;
        _bladerName = 'Guest';
        _profilePictureUrl = '';
      });
      sl<NavigationService>().navigateTo('/login');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Widget _buildTournamentsCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tournaments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tournaments')
                  .snapshots(),
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
                    id: doc.id,
                    name: doc['name'],
                    date: doc['date'],
                    location: doc['location'],
                    description: doc['description'],
                  );
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Text('Name',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Date',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Location',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Description',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows: events
                        .map((event) => DataRow(
                              cells: [
                                DataCell(Text(event.name)),
                                DataCell(Text(_formatTimestamp(event.date))),
                                DataCell(Text(event.location)),
                                DataCell(Text(event.description)),
                              ],
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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
      home: HomePage(),
    );
  }
}
