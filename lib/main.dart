import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/profile_page.dart';
import 'pages/home_page.dart';
// Import JoinClubPage and CreateClubPage
import 'pages/join_club_page.dart';
import 'pages/create_club_page.dart';

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
        measurementId: "G-XJHHBQTNC6",
      ),
    );
    runApp(MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/profile': (context) => ProfilePage(),
        // Add routes for the Join Club and Create Club pages
        '/join_club': (context) => JoinClubPage(),
        '/create_club': (context) => CreateClubPage(),
      },
    );
  }
}
