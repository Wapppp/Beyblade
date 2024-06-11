import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:js' as js;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signInWithGoogle() async {
    try {
      // Trigger the sign-in flow by calling the JavaScript function directly
      await js.context.callMethod('signInWithGoogle');
    } catch (e) {
      // Handle any errors that occur during sign-in
      print('Error signing in with Google: $e');
    }
  }

  void _storeUserDataInFirestore(User user) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('users');

    try {
      await users.doc(user.uid).set({
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
      });
      print('User data stored in Firestore successfully!');
    } catch (e) {
      print('Error storing user data in Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: Text('Sign in with Google'),
              ),
              Container(
                key: Key('sign-in-button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
