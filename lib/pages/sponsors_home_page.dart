import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/navigation_service.dart';
import 'data/injection_container.dart';

class SponsorsHomePage extends StatefulWidget {
  @override
  _SponsorsHomePageState createState() => _SponsorsHomePageState();
}

class _SponsorsHomePageState extends State<SponsorsHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  String _bladerName = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          _bladerName = userData.get('blader_name') ?? user.displayName ?? 'User';
          _userRole = userData.get('role') ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(_auth.currentUser!.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(child: Text('User not found.')),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        if (userData['role'] != 'sponsors') {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(child: Text('Access Denied')),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.grey[900],
                  child: FutureBuilder<QuerySnapshot>(
                    future: _firestore.collection('sponsors').get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No sponsors found.'));
                      }

                      // Process snapshot data
                      List<DocumentSnapshot> sponsors = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: sponsors.length,
                        itemBuilder: (context, index) {
                          var sponsor = sponsors[index].data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(
                              sponsor['name'],
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              sponsor['contact'],
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            tileColor: Colors.grey[850],
                            onTap: () {
                              // Handle onTap if needed
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  backgroundColor: Colors.white,
                  items: [
                    _buildBottomNavigationBarItem(Icons.home, 'Home'),
                    _buildBottomNavigationBarItem(Icons.event, 'Tournaments'),
                    _buildBottomNavigationBarItem(Icons.leaderboard, 'Rankings'),
                    _buildBottomNavigationBarItem(Icons.group, 'Club'),
                    _buildBottomNavigationBarItem(Icons.newspaper, 'News'),
                  ],
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    _handleNavigation(index);
                  },
                  selectedItemColor: Colors.orange,
                  unselectedItemColor: Colors.grey,
                  type: BottomNavigationBarType.fixed,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(
              'Sponsors List',
              style: TextStyle(color: Colors.grey[300]),
            ),
          ),
          _buildUserDropdown(),
        ],
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        sl<NavigationService>().navigatorKey.currentState!.pushNamed('/sponsorshome');
        break;
      case 1:
        sl<NavigationService>().navigateTo('/tournaments');
        break;
      case 2:
        sl<NavigationService>().navigateTo('/rankings');
        break;
      case 3:
        sl<NavigationService>().navigatorKey.currentState!.pushNamed('/club');
        break;
      case 4: // New case for '/news'
        sl<NavigationService>().navigateTo('/news');
        break;
    }
  }
Widget _buildUserDropdown() {
  if (_auth.currentUser != null) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: 'Hello, $_bladerName',
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]), // Adjust icon color if needed
        onChanged: (String? newValue) {
          if (newValue == 'Logout') {
            _signOut();
          } else if (newValue == 'My Profile') {
            Navigator.pushNamed(context, '/profile');
          } else if (newValue == 'Upgrade Your Account') {
            Navigator.pushNamed(context, '/upgrade'); // Navigate to UpgradeAccountPage
          }
        },
        items: <String>[
          'Hello, $_bladerName',
          'My Profile',
          'Upgrade Your Account', // Add this option
          'Logout'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[500]), // Set text color to white
            ),
          );
        }).toList(),
      ),
    );
  } else {
    return Container();
  }
}

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
}