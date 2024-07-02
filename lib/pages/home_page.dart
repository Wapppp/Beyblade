import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/injection_container.dart';
import 'data/navigation_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  User? _user;
  String _bladerName = '';

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

      setState(() {
        _user = user;
        _bladerName = userData.get('blader_name') ?? user.displayName ?? 'Guest';
      });

      // Fetch photoURL if available
      if (userData.exists && userData.data()!.containsKey('photoURL')) {
        String photoURL = userData.get('photoURL');
        // Use the photoURL as needed
        print('User photoURL: $photoURL');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB8C1EC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            color: Color(0xFFB8C1EC),
            child: Row(
              children: [
                Image.asset(
                  'assets/hehe.png',
                  width: 170,
                ),
                Spacer(),
                _buildUserDropdown(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xFF232946),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to the Beyblade Community!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Add your main content widgets here
                ],
              ),
            ),
          ),
          Container(
            color: Color(0xFFB8C1EC),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex.clamp(0, 3),
              backgroundColor: Color(0xFFB8C1EC),
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
              selectedItemColor: Color.fromARGB(255, 36, 20, 94),
              unselectedItemColor: Colors.grey[900],
              type: BottomNavigationBarType.fixed,
            ),
          ),
        ],
      ),
    );
  }
Widget _buildUserDropdown() {
  if (_user != null) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: 'Hello, $_bladerName',
        icon: Icon(Icons.arrow_drop_down),
        onChanged: (String? newValue) {
          if (newValue == 'Logout') {
            _signOut();
          } else if (newValue == 'My Profile') {
            sl<NavigationService>().navigateTo('/profile');
          } else if (newValue == 'Upgrade Your Account') {
            sl<NavigationService>().navigateTo('/upgrade'); // Navigate to UpgradeAccountPage
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
            child: Text(value),
          );
        }).toList(),
      ),
    );
    } else {
     return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            sl<NavigationService>().navigateTo('/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF232946), // Background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text('Login'),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            sl<NavigationService>().navigateTo('/register');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF232946), // Background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text('Sign Up'),
        ),
      ],
    );
  }
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
        sl<NavigationService>().navigatorKey.currentState!.pushNamed('/home');
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

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      setState(() {
        _user = null;
      });
      sl<NavigationService>().navigateTo('/login');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}