
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
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _user = user;
        _bladerName = userData.get('blader_name') ?? user.displayName ?? 'Guest';
        _profilePictureUrl = userData.get('profile_picture');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB8C1EC), // Updated background color to #B8C1EC
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            color: Color(0xFFB8C1EC), // Top bar background color updated
            child: Row(
              children: [
                Image.asset(
                  'assets/hehe.png', // Replace with your logo image asset path
                  width: 170, // Adjust width as needed
                  // You can adjust height, fit, etc. as per your design requirements
                ),
                Spacer(),
                _buildUserDropdown(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xFF232946), // Main content area background
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'Welcome to the Beyblade Community!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color set to white
                      fontFamily: 'Montserrat', // Example of using a modern font
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Add your main content here
                ],
              ),
            ),
          ),
          Container(
            color: Color(0xFFB8C1EC), // Bottom navigation background color updated
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex.clamp(0, 3),
              backgroundColor: Color(0xFFB8C1EC), // Background color for BottomNavigationBar
              items: [
                _buildBottomNavigationBarItem(Icons.home, 'Home'),
                _buildBottomNavigationBarItem(Icons.event, 'Tournaments'),
                _buildBottomNavigationBarItem(Icons.leaderboard, 'Rankings'),
                _buildBottomNavigationBarItem(Icons.group, 'Club'),
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
      return Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: _profilePictureUrl != null
                ? NetworkImage(_profilePictureUrl!)
                : AssetImage('assets/default_avatar.png'),
            child: _profilePictureUrl == null ? Icon(Icons.person, size: 32) : null,
          ),
          SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'Hello, $_bladerName',
              icon: Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                if (newValue == 'Logout') {
                  _signOut();
                } else if (newValue == 'My Profile') {
                  sl<NavigationService>().navigateTo('/profile');
                }
              },
              items: <String>['Hello, $_bladerName', 'My Profile', 'Logout']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: Colors.white), // Button text color
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          ElevatedButton(
            onPressed: () {
              sl<NavigationService>().navigateTo('/login');
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF232946)), // Background color
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
              ),
            ),
            child: Text('Login'),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              sl<NavigationService>().navigateTo('/register');
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF232946)), // Background color
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
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
        sl<NavigationService>().navigatorKey.currentState!.pushNamed('/tournaments');
        break;
      case 2:
        sl<NavigationService>().navigatorKey.currentState!.pushNamed('/rankings');
        break;
      case 3:
        sl<NavigationService>().navigatorKey.currentState!.pushNamed('/club');
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