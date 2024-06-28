import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_colors.dart'; // Import your AppColors class

class OrganizerLoginPage extends StatefulWidget {
  @override
  _OrganizerLoginPageState createState() => _OrganizerLoginPageState();
}

class _OrganizerLoginPageState extends State<OrganizerLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithEmailAndPassword() async {
    try {
      // Sign in with email and password
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Check if the organizer exists in Firestore
        bool isValidOrganizer =
            await _checkOrganizerExists(userCredential.user!.uid);

        if (isValidOrganizer) {
          // Check if email is verified
          if (userCredential.user!.emailVerified) {
            Navigator.pushReplacementNamed(context, '/organizer');
          } else {
            // If email not verified, show error and sign out
            await _auth.signOut();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please verify your email to login')),
            );
          }
        } else {
          // If not a valid organizer, sign out and show error
          await _auth.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid organizer details')),
          );
        }
      }
    } catch (e) {
      print('Error during login: $e');
      // Handle login errors here
    }
  }

  Future<bool> _checkOrganizerExists(String organizerUid) async {
    try {
      // Check if the organizer exists in Firestore
      DocumentSnapshot organizerSnapshot =
          await _firestore.collection('organizers').doc(organizerUid).get();

      return organizerSnapshot.exists;
    } catch (e) {
      print('Error checking organizer existence: $e');
      return false;
    }
  }

  Future<void> _signInWithGoogle() async {
    // Implement Google Sign-In logic similar to what you have
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 33, 33),
      appBar: AppBar(
        title: Text('Organizer Login'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.grey[200]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.grey[200]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _signInWithEmailAndPassword,
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(AppColors.primaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 0),
                ),
                elevation: MaterialStateProperty.all<double>(5),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.appBarColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: double.infinity,
                    minHeight: 50.0,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    AppColors.googleButtonColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.black],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: double.infinity,
                    minHeight: 50.0,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/google.png', height: 24.0),
                      SizedBox(width: 14.0),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}