import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                child: Text('Login'),
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
