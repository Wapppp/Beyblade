import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class OrganizerLoginPage extends StatefulWidget {
  @override
  _OrganizerLoginPageState createState() => _OrganizerLoginPageState();
}

class _OrganizerLoginPageState extends State<OrganizerLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _registerWithEmailAndPassword() async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await _storeOrganizerDataInFirestore(userCredential.user!);
        Navigator.pushReplacementNamed(context, '/organizer');
      }
    } catch (e) {
      print('Error during registration: $e');
      // Handle registration errors here
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
          await _storeOrganizerDataInFirestore(user);
          Navigator.pushReplacementNamed(context, '/organizer');
        }
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
    }
  }

  Future<void> _storeOrganizerDataInFirestore(User user) async {
    try {
      // Store user data in Firestore with 'role' set to 'organizer'
      await _firestore.collection('organizers').doc(user.uid).set({
        'organizer_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'photoUrl': user.photoURL ?? '',
        'role': 'organizer', // Assigning role as 'organizer'
      });
    } catch (e) {
      print('Error storing organizer data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer Login Page'),
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
              child: Text('Register as Organizer'),
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
          ],
        ),
      ),
    );
  }
}
