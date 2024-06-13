import 'package:flutter/material.dart';
import 'data/injection_container.dart';
import 'data/home_view_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final navigationService = sl<NavigationService>();

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('BeybladeX'),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
              navigationService.navigateTo('/login');
            },
          ),
          IconButton(
            icon: Icon(Icons.app_registration),
            onPressed: () {
              navigationService.navigateTo('/register');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align text at the top
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch text to full width
          children: <Widget>[
            Text(
              'Welcome to the Beyblade Community!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Add space between text and button
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
        // Handle navigation to home page
        break;
      case 1:
        // Handle navigation to tournaments page
        break;
      case 2:
        // Handle navigation to rankings page
        break;
      case 3:
        // Handle navigation to club page
        break;
    }
  }
}