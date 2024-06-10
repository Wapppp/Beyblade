import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
          IconButton(
            icon: Icon(Icons.app_registration),
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to the Beyblade Community!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Text('Go to Profile'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? BottomNavigationBar(
              items: [
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
                  icon: Icon(Icons.shop),
                  label: 'Shop',
                ),
              ],
              onTap: (index) {
                // Handle navigation
              },
            )
          : null,
    );
  }
}
