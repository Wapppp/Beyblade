import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beyblade/pages/login_page.dart'; // Replace with your login page import
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
  String _sponsorName = '';
  String _userRole = '';
  String _bladerName = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final sponsorSnapshot = await _firestore
            .collection('sponsors')
            .where('created_by', isEqualTo: user.uid)
            .get();

        if (sponsorSnapshot.docs.isNotEmpty) {
          setState(() {
            _sponsorName = sponsorSnapshot.docs.first.get('sponsor_name') ?? 'Sponsor';
            // Check if 'role' field exists before setting
            if (sponsorSnapshot.docs.first.data().containsKey('role')) {
              _userRole = sponsorSnapshot.docs.first.get('role');
            } else {
              _userRole = ''; // Handle default or fallback role here
            }
          });
        } else {
          // If no sponsor found for the user, set default values
          setState(() {
            _sponsorName = 'Sponsor'; // Default name if not found
            _userRole = '';
          });
        }
      } catch (e) {
        print('Error fetching sponsor information: $e');
        // Handle error if necessary
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(), // Integrated bottom navigation bar
      backgroundColor: Colors.grey[900], // Setting background color
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false, // This will remove the back button
      title: Text(
        _sponsorName, // Displaying sponsor_name as the title
        style: TextStyle(color: Colors.grey[300], fontSize: 24),
      ),
      actions: [
        _buildUserDropdown(), // Dropdown for user actions
      ],
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

  Widget _buildBody() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/inviteplayers'); // Navigate to InvitePlayersPage
        },
        child: Text('Invite Players', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  DropdownButtonHideUnderline _buildUserDropdown() {
    if (_auth.currentUser != null) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'Hello, $_bladerName',
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]), // Adjust icon color if needed
          onChanged: (String? newValue) {
            if (newValue == 'Logout') {
              _signOut(); // Call _signOut method here
            } else if (newValue == 'My Profile') {
              Navigator.pushNamed(context, '/profile');
            } else if (newValue == 'Sponsor Profile') {
              Navigator.pushNamed(context, '/sponsorprofile'); // Navigate to SponsorProfilePage
            }
          },
          items: <String>[
            'Hello, $_bladerName',
            'My Profile',
            'Sponsor Profile', // Add this option
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
      return DropdownButtonHideUnderline(child: Container());
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavigationBarTapped,
      backgroundColor: Colors.grey[900], // Keeping the background color
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Tournaments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: 'Rankings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Club',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.newspaper),
          label: 'News',
        ),
      ],
    );
  }

  void _onBottomNavigationBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    switch (index) {
      case 0:
        sl<NavigationService>().navigatorKey.currentState!.pushNamed('/sponsorshome');
        break;
      case 1:
        Navigator.pushNamed(context, '/tournaments');
        break;
      case 2:
        Navigator.pushNamed(context, '/rankings');
        break;
      case 3:
        Navigator.pushNamed(context, '/club');
        break;
      case 4:
        Navigator.pushNamed(context, '/news');
        break;
    }
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}