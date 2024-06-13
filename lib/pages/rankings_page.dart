import 'package:flutter/material.dart';
import 'package:beyblade/pages/data/injection_container.dart'; // Import sl and NavigationService

class RankingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rankings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Rankings Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sl<NavigationService>().navigateTo('/profile'); // Example navigation using NavigationService
              },
              child: Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}