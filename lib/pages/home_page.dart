import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/injection_container.dart'; // Import sl from here
import 'data/home_view_model.dart';

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
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _user = user;
        _bladerName = userData.get('blader_name') ?? user.displayName ?? 'Guest';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Row(
          children: [
            Text('BeybladeX'),
            Spacer(),
            _buildUserDropdown(),
          ],
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex.clamp(0, 3),
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
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
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
            }
          },
          items: <String>['Hello, $_bladerName', 'My Profile', 'Logout'].map<DropdownMenuItem<String>>((String value) {
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
          TextButton(
            onPressed: () {
              sl<NavigationService>().navigateTo('/login');
            },
            child: Text('Login'),
          ),
          SizedBox(width: 10),
          TextButton(
            onPressed: () {
              sl<NavigationService>().navigateTo('/register');
            },
            child: Text('Sign Up'),
          ),
        ],
      );
    }
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
        sl<NavigationService>().navigateTo('/home'); // Navigate to Home page
        break;
      case 1:
        sl<NavigationService>().navigateTo('/tournaments'); // Navigate to Tournaments page
        break;
      case 2:
        sl<NavigationService>().navigateTo('/rankings'); // Navigate to Rankings page
        break;
      case 3:
        sl<NavigationService>().navigateTo('/club'); // Navigate to Club page
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