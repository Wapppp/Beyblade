import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
        await _storeUserDataInFirestore(userCredential.user!, name, email);
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    } catch (e) {
      throw 'Failed to register. Please try again later.';
    }
    return null;
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    } catch (e) {
      throw 'Failed to sign in. Please try again later.';
    }
  }

  Future<void> _storeUserDataInFirestore(
      User user, String name, String email) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'blader_name': name,
        'email': email,
        'points': 0,
        'rank': 'No Rank',
        'won': 0,
        'lost': 0,
      });
    } catch (e) {
      throw 'Error storing user data in Firestore: $e';
    }
  }

  String _handleAuthError(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'user-disabled':
        return 'The user account has been disabled by an administrator.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'network-request-failed':
        return 'Network error occurred. Please check your internet connection.';
      default:
        return 'Authentication failed. Please try again later.';
    }
  }
}
