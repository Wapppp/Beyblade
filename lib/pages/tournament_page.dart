import 'package:flutter/material.dart';
import 'package:beyblade/pages/data/injection_container.dart';
import 'data/navigation_service.dart';

class TournamentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournaments'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Tournaments Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sl<NavigationService>().navigateTo(
                    '/profile'); // Example navigation using NavigationService
              },
              child: Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
