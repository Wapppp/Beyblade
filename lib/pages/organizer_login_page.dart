import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          Navigator.pushReplacementNamed(context, '/organizer');
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
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken!,
          idToken: googleAuth.idToken!,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          // Check if the organizer exists in Firestore
          bool isValidOrganizer = await _checkOrganizerExists(user.uid);

          if (isValidOrganizer) {
            Navigator.pushReplacementNamed(context, '/organizer');
          } else {
            // If not a valid organizer, sign out and show error
            await _auth.signOut();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid organizer details')),
            );
          }
        }
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _signInWithEmailAndPassword,
              child: Text('Login'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/google.png', height: 24.0),
                  SizedBox(width: 12.0),
                  Text('Sign in with Google'),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register_organizer');
              },
              child: Text('Register as Organizer'),
            ),
          ],
        ),
      ),
    );
  }
}
