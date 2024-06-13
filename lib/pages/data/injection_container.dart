import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart'; // Ensure material.dart is imported

final sl = GetIt.instance;

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

void setupLocator() {
  sl.registerLazySingleton(() => NavigationService());
}