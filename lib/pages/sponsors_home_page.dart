import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beyblade/pages/login_page.dart'; // Replace with your login page import
import 'data/navigation_service.dart';
import 'data/injection_container.dart';

class SponsorHomePage extends StatefulWidget {
  @override
  _SponsorHomePageState createState() => _SponsorHomePageState();
}

class _SponsorHomePageState extends State<SponsorHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  String _sponsorName = '';
  String _userRole = '';
  String _bladerName = '';
  String _userId = ''; // New field to store the userId

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          print('User Data: $userData'); // Debug print

          setState(() {
            _bladerName = userData['blader_name'] ?? '';
            _userRole = userData['role'] ?? '';
            _userId = user.uid; // Store the userId

            // Check if the user has a sponsor_id and load sponsor details if applicable
            final sponsorId = userData['sponsor_id'];
            if (sponsorId != null && sponsorId.isNotEmpty) {
              _loadSponsorDetails(sponsorId);
            } else {
              _sponsorName = 'Sponsor';
            }
          });
        } else {
          setState(() {
            _sponsorName = 'Sponsor';
            _userRole = '';
            _bladerName = user.displayName ?? '';
          });
        }
      } catch (e) {
        print('Error fetching user information: $e');
      }
    }
  }

  void _loadSponsorDetails(String sponsorId) async {
    try {
      final sponsorDoc =
          await _firestore.collection('sponsors').doc(sponsorId).get();

      if (sponsorDoc.exists) {
        setState(() {
          _sponsorName = sponsorDoc.get('sponsor_name') ?? 'Sponsor';
        });
      } else {
        setState(() {
          _sponsorName = 'Sponsor';
        });
      }
    } catch (e) {
      print('Error fetching sponsor information: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      backgroundColor: Colors.grey[900],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        _sponsorName,
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      actions: [
        IconButton(
          color: Colors.lightBlue,
          icon: Icon(Icons.notifications),
          onPressed: () {
            _navigateToNotifications(); // Navigate to notifications page
          },
        ),
        _buildUserDropdown(),
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
    print('User Role: $_userRole'); // Add this line to debug

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_userRole == 'sponsors') ...[
            ElevatedButton(
              onPressed: () {
                _navigateToInvitePlayers(); // Navigate to invite players page
              },
              child: Text('Invite Players', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _navigateToInviteClubs(); // Navigate to invite clubs page
              },
              child: Text('Invite Club', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  DropdownButtonHideUnderline _buildUserDropdown() {
    if (_auth.currentUser != null) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'Hello, $_bladerName',
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[900]),
          dropdownColor: Colors.grey[900],
          onChanged: (String? newValue) {
            if (newValue == 'Logout') {
              _signOut();
            } else if (newValue == 'My Profile') {
              _navigateToProfile();
            } else if (newValue == 'Sponsor Profile') {
              _navigateToSponsorProfile();
            }
          },
          items: <String>[
            'Hello, $_bladerName',
            'My Profile',
            'Sponsor Profile',
            'Logout'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                    color: Colors.grey[100]), // Color for dropdown items
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
      backgroundColor: Colors.grey[900],
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
    switch (index) {
      case 0:
        sl<NavigationService>()
            .navigatorKey
            .currentState!
            .pushNamed('/sponsorhome');
        break;
      case 1:
        _navigateToProfile();
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

  void _navigateToInvitePlayers() {
    Navigator.pushNamed(context, '/invitesponsorplayer', arguments: _userId);
  }

  void _navigateToInviteClubs() {
    Navigator.pushNamed(context, '/invitesponorclubs', arguments: _userId);
  }

  void _navigateToNotifications() {
    Navigator.pushNamed(context, '/inviteresponse', arguments: _userId);
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _navigateToSponsorProfile() {
    Navigator.pushNamed(context, '/sponsorprofile');
  }
}
