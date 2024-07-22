import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_management_page.dart';
import 'club_management.dart';
import 'tournaments_manage_page.dart';
import 'manage_rankings.dart';
import 'content_management_page.dart'; // Ensure this import is correct
import 'chart_page.dart'; // Import the chart page
import 'news_management_page.dart';
import 'manage_invitations.dart';

class AdminPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(_auth.currentUser?.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Text('Access Denied',
                  style: TextStyle(color: Colors.red, fontSize: 18)),
            ),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        if (userData['role'] != 'admin') {
          return Scaffold(
            body: Center(
              child: Text('Access Denied',
                  style: TextStyle(color: Colors.red, fontSize: 18)),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title:
                Text('Admin Panel', style: TextStyle(color: Colors.grey[300])),
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
          drawer: Drawer(
            child: Container(
              color: Colors.grey[850],
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text(
                      'Admin Menu',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  _createDrawerItem(
                    icon: Icons.dashboard,
                    text: 'Dashboard',
                    onTap: () => Navigator.pop(context),
                  ),
                  _createDrawerItem(
                    icon: Icons.people,
                    text: 'Manage Users',
                    onTap: () => _navigateTo(context, UserManagementPage()),
                  ),
                  _createDrawerItem(
                    icon: Icons.mail,
                    text: 'Manage Invitations',
                    onTap: () =>
                        _navigateTo(context, AdminManageInvitationsPage()),
                  ),
                  _createDrawerItem(
                    icon: Icons.content_paste,
                    text: 'Manage Content',
                    onTap: () => _navigateTo(context,
                        ContentManagementPage()), // Ensure this class exists
                  ),
                  _createDrawerItem(
                    icon: Icons.sports,
                    text: 'Manage Tournaments',
                    onTap: () => _navigateTo(context, TournamentsManagePage()),
                  ),
                  _createDrawerItem(
                    icon: Icons.group_work,
                    text: 'Manage Clubs',
                    onTap: () => _navigateTo(context, ClubManagementPage()),
                  ),
                  _createDrawerItem(
                    icon: Icons.leaderboard,
                    text: 'Manage Rankings',
                    onTap: () => _navigateTo(context, ManageRankingsPage()),
                  ),
                  _createDrawerItem(
                    icon: Icons.bar_chart,
                    text: 'View Charts',
                    onTap: () => _navigateTo(
                        context, ChartPage()), // Navigate to the chart page
                  ),
                  _createDrawerItem(
                    icon: Icons.newspaper,
                    text: 'News Management',
                    onTap: () => _navigateTo(context,
                        NewsManagementPage()), // Navigate to the notifications page
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            color: Colors.grey[900],
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _fetchDashboardData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildDashboardCard(
                              icon: Icons.people,
                              title: 'Users',
                              content: snapshot.data?['users'] ?? 'Loading...',
                            ),
                            _buildDashboardCard(
                              icon: Icons.event,
                              title: 'Tournaments',
                              content:
                                  snapshot.data?['tournaments'] ?? 'Loading...',
                            ),
                            _buildDashboardCard(
                              icon: Icons.group_work,
                              title: 'Clubs',
                              content: snapshot.data?['clubs'] ?? 'Loading...',
                            ),
                            _buildDashboardCard(
                              icon: Icons.leaderboard,
                              title: 'Rankings',
                              content: 'Updated', // Placeholder or dynamic data
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon, color: Colors.white),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child:
                Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
      tileColor: Colors.grey[850],
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    try {
      // Fetch counts from Firestore
      final usersCount = await FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((value) => value.docs.length.toString());
      final tournamentsCount = await FirebaseFirestore.instance
          .collection('tournaments')
          .get()
          .then((value) => value.docs.length.toString());
      final clubsCount = await FirebaseFirestore.instance
          .collection('clubs')
          .get()
          .then((value) => value.docs.length.toString());

      return {
        'users': usersCount,
        'tournaments': tournamentsCount,
        'clubs': clubsCount,
      };
    } catch (e) {
      print('Error fetching dashboard data: $e');
      return {}; // Return empty data or handle error as needed
    }
  }

  Widget _buildDashboardCard(
      {required IconData icon,
      required String title,
      required String content}) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
