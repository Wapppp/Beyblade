import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  String _welcomeMessage = 'Welcome to the Beyblade Community!';

  // Getter for welcome message
  String get welcomeMessage => _welcomeMessage;

  // Method to update the welcome message
  void updateWelcomeMessage(String message) {
    _welcomeMessage = message;
    notifyListeners(); // Notify listeners to update UI
  }

  // Method to fetch data from an external source
  Future<void> fetchData() async {
    // Simulate fetching data from a server
    await Future.delayed(Duration(seconds: 2));
    // Update welcome message with fetched data
    updateWelcomeMessage('Fetched data from server');
  }
}