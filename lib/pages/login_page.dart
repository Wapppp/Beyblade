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
  bool _isLoading = false;
  String? _errorMessage;

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
      setState(() {
        _errorMessage =
            'Failed to sign in with Google. Please try again later.';
      });
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
      setState(() {
        _errorMessage = 'Failed to fetch user data. Please try again later.';
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _handleLogin(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = _handleAuthError(e.code);
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to sign in. Please try again later.';
      });
    }
  }

  String _handleAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password provided.';
      case 'network-request-failed':
        return 'Network error occurred. Please check your internet connection.';
      default:
        return 'Authentication error occurred. Please try again later.';
    }
  }

  void _navigateToRegistration() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(color: Colors.grey[300]),
        ),
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
      body: Container(
        color: Colors.grey[900],
        child: Center(
          child: Card(
            color: Colors.grey[850],
            margin: EdgeInsets.symmetric(horizontal: 20),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey[200]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey[200]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
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
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.orange), // Background color
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.symmetric(horizontal: 0)),
                            elevation: MaterialStateProperty.all<double>(5),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange, Colors.black],
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
                  SizedBox(height: 10), // Adjust spacing
                  ElevatedButton(
                    onPressed: _signInWithGoogle,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.red), // Example color
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 0)),
                      elevation: MaterialStateProperty.all<double>(5),
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
                        child: Text(
                          'Login with Google',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: _navigateToRegistration,
                    child: Text(
                      'Create an account',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
