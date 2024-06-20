import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class OrganizerRegisterPage extends StatefulWidget {
  @override
  _OrganizerRegisterPageState createState() => _OrganizerRegisterPageState();
}

class _OrganizerRegisterPageState extends State<OrganizerRegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _registerWithEmailAndPassword() async {
    try {
      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Store organizer data in Firestore
        await _storeOrganizerDataInFirestore(userCredential.user!);

        // Navigate to organizer page
        Navigator.pushReplacementNamed(context, '/organizer');
      }
    } catch (e) {
      print('Error during registration: $e');
      // Handle registration errors here
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Sign in with Google
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
          // Store organizer data in Firestore
          await _storeOrganizerDataInFirestore(user);

          // Navigate to organizer page
          Navigator.pushReplacementNamed(context, '/organizer');
        }
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
    }
  }

  Future<void> _storeOrganizerDataInFirestore(User user) async {
    try {
      // Store organizer details in Firestore under 'organizers' collection
      await _firestore.collection('organizers').doc(user.uid).set({
        'organizer_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'photoUrl': user.photoURL ?? '',
        'role': 'organizer',
      });
    } catch (e) {
      print('Error storing organizer data: $e');
    }
  }

  void _navigateToOrganizerLoginPage() {
    Navigator.pushReplacementNamed(context, '/organizer_login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Organizer Name'),
            ),
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
              onPressed: _registerWithEmailAndPassword,
              child: Text('Register'),
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
            SizedBox(height: 10.0),
            TextButton(
              onPressed: _navigateToOrganizerLoginPage,
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
