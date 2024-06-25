import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/injection_container.dart'; // Import dependency injection container
import 'data/navigation_service.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'BeybladeX',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: _buildAppBarActions(),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Welcome to the Beyblade Community!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[200],
              ),
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
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.grey[850],
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
                : AssetImage('assets/images/default_profile.png'),
          ),
        ),
        SizedBox(width: 8),
        Text(
          _bladerName,
          style: TextStyle(fontSize: 16, color: Colors.grey[300]),
        ),
        SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[300]),
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
          icon: Icon(Icons.login, color: Colors.grey[300]),
          onPressed: () {
            sl<NavigationService>().navigateTo('/login');
          },
        ),
        IconButton(
          icon: Icon(Icons.app_registration, color: Colors.grey[300]),
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
      color: Colors.grey[850],
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
                color: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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

                  final List<TournamentEvent> events =
                      snapshot.data!.docs.map((doc) {
                    return TournamentEvent(
                      id: doc.id,
                      name: doc['name'],
                      date: doc['date'],
                      location: doc['location'],
                      description: doc['description'],
                    );
                  }).toList();

                  return Scrollbar(
                    thumbVisibility: true,
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Text('Name',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Date',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Location',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Description',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                        rows: events
                            .map((event) => DataRow(
                                  cells: [
                                    DataCell(Text(event.name,
                                        style: TextStyle(color: Colors.white))),
                                    DataCell(Text(_formatTimestamp(event.date),
                                        style: TextStyle(color: Colors.white))),
                                    DataCell(Text(event.location,
                                        style: TextStyle(color: Colors.white))),
                                    DataCell(Text(event.description,
                                        style: TextStyle(color: Colors.white))),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime);
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
