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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

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
    try {
      await _firestore.collection('users').doc(user.uid).set({
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
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Blader Name'),
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
                onPressed: () async {
                  try {
                    final UserCredential userCredential =
                        await _auth.createUserWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );
                    if (userCredential.user != null) {
                      await _firestore
                          .collection('users')
                          .doc(userCredential.user!.uid)
                          .set({
                        'blader_name': _nameController.text.trim(),
                        'email': _emailController.text.trim(),
                      });
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  } on FirebaseAuthException catch (e) {
                    print('FirebaseAuthException: $e');
                    // Handle FirebaseAuthException here
                  } catch (e) {
                    print('Error: $e');
                    // Handle other errors here
                  }
                },
                child: Text('Register'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: Text('Sign in with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
