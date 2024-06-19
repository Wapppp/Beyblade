import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _storeUserDataInFirestore(userCredential.user!);
        }
        _handleLogin(userCredential.user!);
      } else {
        print('Google Sign In canceled');
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  Future<void> _storeUserDataInFirestore(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
      });
      print('User data stored in Firestore successfully!');
    } catch (e) {
      print('Error storing user data in Firestore: $e');
    }
  }

  Future<void> _handleLogin(User user) async {
    try {
      // Check if the user exists in 'users' collection
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      // Check if the user exists in 'organizers' collection
      DocumentSnapshot<Map<String, dynamic>> organizerSnapshot =
          await FirebaseFirestore.instance
              .collection('organizers')
              .doc(user.uid)
              .get();

      // Determine user role
      String? userRole;
      if (userSnapshot.exists) {
        userRole = userSnapshot.data()?['role'];
      } else if (organizerSnapshot.exists) {
        userRole = organizerSnapshot.data()?['role'];
      }

      // Navigate based on user role
      if (userRole == 'organizer') {
        Navigator.pushReplacementNamed(context, '/organizer');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
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
                onPressed: () async {
                  try {
                    final UserCredential userCredential =
                        await _auth.signInWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );
                    if (userCredential.user != null) {
                      _handleLogin(userCredential.user!);
                    }
                  } on FirebaseAuthException catch (e) {
                    print('FirebaseAuthException: $e');
                    // Handle FirebaseAuthException here
                  } catch (e) {
                    print('Error: $e');
                    // Handle other errors here
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 10.0), // Adjust spacing
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: Text('Login with Google'),
              ),
              SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
