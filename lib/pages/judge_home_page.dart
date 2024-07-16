import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beyblade/pages/login_page.dart'; // Replace with your login page import
import 'data/navigation_service.dart';
import 'data/injection_container.dart';
import 'package:intl/intl.dart';

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

class JudgeHomePage extends StatefulWidget {
  @override
  _JudgeHomePageState createState() => _JudgeHomePageState();
}

class _JudgeHomePageState extends State<JudgeHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  String _judgeName = '';
  String _userRole = '';
  String _bladerName = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCurrentJudge();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCurrentJudge() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final judgeSnapshot = await _firestore.collection('judges').doc(user.uid).get();

        if (judgeSnapshot.exists) {
          setState(() {
            _judgeName = judgeSnapshot.get('judge_name') ?? 'Judge';
            // Adjust according to your Firestore structure for judge roles
            _userRole = 'Judge'; // Assuming judge role identifier
          });
        } else {
          setState(() {
            _judgeName = 'Judge';
            _userRole = '';
          });
        }
      } catch (e) {
        print('Error fetching judge information: $e');
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
        _judgeName,
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
          // Adjust content as per judge's functionalities
          Text(
            'Welcome, $_judgeName!',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            'Judge specific content here',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _buildTournamentsCard(),
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
            }
          },
          items: <String>[
            'Hello, $_bladerName',
            'My Profile',
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
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: 'Rankings',
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
        sl<NavigationService>().navigatorKey.currentState!.pushNamed('/judgehome');
        break;
      case 1:
        Navigator.pushNamed(context, '/tournaments');
        break;
      case 2:
        Navigator.pushNamed(context, '/rankings');
        break;
      case 3:
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
                stream: FirebaseFirestore.instance.collection('tournaments').snapshots(),
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

                  final List<TournamentEvent> events = snapshot.data!.docs.map((doc) {
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
                                DateFormat('dd MMMM yyyy').format(event.date.toDate()),
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