import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'forgot_password_page.dart';
import 'organizer_login_page.dart';
import 'sponsors_home_page.dart';
import 'agency_home_page.dart';
import 'judge_home_page.dart';
import 'home_page.dart'; // Import the HomePage widget

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final AuthService _authService = AuthService();

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        if (user.emailVerified) {
          await _checkUserRole(user.uid);
        } else {
          setState(() {
            _errorMessage = 'Please verify your email before logging in.';
          });
          await _authService.signOut();
        }
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkUserRole(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      String? role = userData?['role'];

      if (role == 'sponsors') {
        _navigateToSponsorsHomePage();
      } else if (role == 'agency') {
        _navigateToAgencyHomePage();
      } else if (role == 'judge') {
        _navigateToJudgeHomePage();
      } else if (role == null || role.isEmpty) {
        _navigateToHomePage(); // Navigate to HomePage if no role is found
      } else {
        setState(() {
          _errorMessage = 'You are not allowed to login here.';
        });
        await _authService.signOut();
      }
    } else {
      setState(() {
        _errorMessage = 'User data not found.';
      });
      await _authService.signOut();
    }
  }

  void _navigateToSponsorsHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SponsorHomePage()),
    );
  }

  void _navigateToAgencyHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AgencyHomePage()),
    );
  }

  void _navigateToJudgeHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => JudgeHomePage()),
    );
  }

  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
  }

  void _navigateToOrganizerLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrganizerLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: Colors.grey[300])),
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
      body: Stack(
        children: [
          Container(
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[200],
                          ),
                        ),
                        SizedBox(height: 20),
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
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 20),
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
                        SizedBox(height: 20),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _login,
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                    Colors.orange,
                                  ),
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
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: _navigateToForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.grey[200],
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToOrganizerLoginPage,
        backgroundColor: Colors.orange,
        icon: Icon(Icons.group_add),
        label: Text("Organizer Login"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}