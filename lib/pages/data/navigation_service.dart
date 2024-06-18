import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) async {
    if (navigatorKey.currentState != null) {
      return navigatorKey.currentState!.pushNamed(routeName);
    } else {
      print('Error: Navigator currentState is null');
      return null;
    }
  }

  void goBack() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pop();
    }
  }
}