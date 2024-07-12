import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/navigation_service.dart';
import 'data/injection_container.dart';

class JudgeHomePage extends StatefulWidget {
  @override
  _JudgeHomePageState createState() => _JudgeHomePageState();
}

class _JudgeHomePageState extends State<JudgeHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String _bladerName = '';
  String _userRole = '';
  int _selectedIndex = 0;

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
          _user = user;
          _bladerName = userData.get('blader_name') ?? user.displayName ?? 'Judge';
          _userRole = userData.get('role') ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check user role and redirect if not authorized
    if (_userRole != 'judge') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return Container(); // Return an empty container while redirecting
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Judge Home Page',
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
      ),
      body: _user != null && _userRole == 'judge'
          ? Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome, $_bladerName!',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        // Add your judge-specific widgets here
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
            )
          : Center(
              child: Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
              child: Text(value),
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