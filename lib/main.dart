import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart'; // Import LoginPage
import 'pages/register_page.dart'; // Import RegisterPage
import 'pages/profile_page.dart'; // Import ProfilePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "...",
        authDomain: "...",
        projectId: "...",
        storageBucket: "...",
        messagingSenderId: "...",
        appId: "...",
        measurementId: "...",
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
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => ProfilePage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}
