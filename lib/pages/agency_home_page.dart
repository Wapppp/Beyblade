import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beyblade/pages/login_page.dart'; // Replace with your login page import
import 'data/navigation_service.dart';
import 'data/injection_container.dart';

class AgencyHomePage extends StatefulWidget {
  @override
  _AgencyHomePageState createState() => _AgencyHomePageState();
}

class _AgencyHomePageState extends State<AgencyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  String _agencyName = '';
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
        final agencySnapshot = await _firestore
            .collection('agencies')
            .where('created_by', isEqualTo: user.uid)
            .get();

        if (agencySnapshot.docs.isNotEmpty) {
          setState(() {
            _agencyName =
                agencySnapshot.docs.first.get('agency_name') ?? 'Agency';
            if (agencySnapshot.docs.first.data().containsKey('role')) {
              _userRole = agencySnapshot.docs.first.get('role');
            } else {
              _userRole = '';
            }
          });
        } else {
          setState(() {
            _agencyName = 'Agency';
            _userRole = '';
          });
        }
      } catch (e) {
        print('Error fetching agency information: $e');
      }
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
        _agencyName,
        style: TextStyle(color: Colors.grey[300], fontSize: 24),
      ),
      actions: [
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/inviteplayers');
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
              Navigator.pushNamed(context, '/inviteclubs');
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
      ),
    );
  }

  DropdownButtonHideUnderline _buildUserDropdown() {
    if (_auth.currentUser != null) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'Hello, $_bladerName',
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
          onChanged: (String? newValue) {
            if (newValue == 'Logout') {
              _signOut();
            } else if (newValue == 'My Profile') {
              Navigator.pushNamed(context, '/profile');
            } else if (newValue == 'Agency Profile') {
              Navigator.pushNamed(context, '/agencyprofile');
            }
          },
          items: <String>[
            'Hello, $_bladerName',
            'My Profile',
            'Agency Profile',
            'Logout'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: Colors.grey[500]),
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
            .pushNamed('/agencyhome');
        break;
      case 1:
        Navigator.pushNamed(context, '/profile');
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
