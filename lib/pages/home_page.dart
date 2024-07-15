import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/injection_container.dart'; // Import dependency injection container
import 'data/navigation_service.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'upgrade_account_page.dart'; // Import the UpgradeAccountPage

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
    try {
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
    } catch (e) {
      print('Error loading user data: $e');
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
          _buildBottomNavigationBarItem(Icons.newspaper, 'News'),
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
                : AssetImage('assets/images/default_profile.png') as ImageProvider,
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
            } else if (value == 'upgrade') {
              _navigateToUpgrade();
               } else if (value == 'mail') {
              _navigateToMail();
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
              value: 'upgrade',
              child: ListTile(
                leading: Icon(Icons.upgrade_sharp),
                title: Text('Upgrade your account?'),
              ),
            ),
               PopupMenuItem<String>(
              value: 'mail',
              child: ListTile(
                leading: Icon(Icons.mail),
                title: Text('Mail'),
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

  void _navigateToUpgrade() {
    sl<NavigationService>().navigateTo('/upgrade');
  }

    void _navigateToMail() {
    sl<NavigationService>().navigateTo('/mail');
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
      case 4:
        sl<NavigationService>().navigateTo('/news');
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

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading tournaments',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
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
                      date: doc['event_date_time'],
                      location: doc['location'],
                      description: doc['description'],
                    );
                  }).toList();

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        color: Colors.grey[800],
                        child: ListTile(
                          title: Text(
                            event.name,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd MMMM yyyy')
                                    .format(event.date.toDate()),
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              Text(
                                event.location,
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              Text(
                                event.description,
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator(); // Initialize dependency injection
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeybladeX',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      navigatorKey: sl<NavigationService>().navigatorKey,
      routes: {
        '/': (context) => HomePage(),
        '/upgrade': (context) => UpgradeAccountPage(), // Define the route for UpgradeAccountPage
      
      },
      initialRoute: '/',
    );
  }
}