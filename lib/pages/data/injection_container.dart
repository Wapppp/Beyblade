import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

final sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton(() => NavigationService());
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) async {
    if (navigatorKey.currentState != null) {
      return navigatorKey.currentState!.pushNamed(routeName);
    } else {
      // Handle the case where currentState is null
      print('Error: Navigator currentState is null');
      return null;
    }
  }

  void goBack() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pop();
    }
    // Optionally, you can handle the case where currentState is null
  }
}