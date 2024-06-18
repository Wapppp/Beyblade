import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:js' as js;

// Import your pages
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/profile_page.dart';
import 'pages/home_page.dart';
import 'pages/create_club_page.dart';
import 'pages/rankings_page.dart';
import 'pages/tournament_page.dart';
import 'pages/join_club_page.dart';
import 'pages/club_detail_page.dart';
import 'pages/tournaments_page.dart'; // Import TournamentsPage

// Import your local dependencies
import 'pages/data/injection_container.dart'; // Import sl from here
import 'pages/data/navigation_service.dart';
import 'pages/data/home_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBLRd6X2X7mZ_lEHlGZzv0A_H9S6L1jqxA",
        authDomain: "test123-7ff7e.firebaseapp.com",
        projectId: "test123-7ff7e",
        storageBucket: "test123-7ff7e.appspot.com",
        messagingSenderId: "498981798184",
        appId: "1:498981798184:web:3d567a05bd78108d5a901d",
        measurementId: "G-XJHHBQTNC6"
      ),
    );

    setupLocator(); // Initialize GetIt and setup NavigationService
    runApp(MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: MaterialApp(
        title: 'Flutter Firebase Auth',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/', // Set initial route
        routes: {
          '/': (context) => HomePage(),
          '/home': (context) => HomePage(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/profile': (context) => ProfilePage(),
          '/join_club': (context) => JoinClubPage(),
          '/club': (context) => JoinClubPage(),
          '/create_club': (context) => CreateClubPage(),
          '/rankings': (context) => RankingsPage(),
          '/tournaments': (context) => TournamentsPage(), // Add the route for TournamentsPage
        },
        navigatorKey: sl<NavigationService>().navigatorKey, // Set navigatorKey from GetIt
      ),
    );
  }
}