
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpgradeAccountPage extends StatefulWidget {
  @override
  _UpgradeAccountPageState createState() => _UpgradeAccountPageState();
}

class _UpgradeAccountPageState extends State<UpgradeAccountPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _upgradeDetailsController = TextEditingController();
  String _selectedRole = 'Agency'; // Default role option
void _assignRole(String role) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final currentRole = userData['role'];

        if (currentRole == null || currentRole == 'users') {
          // Allow upgrade
          await _firestore.collection('users').doc(user.uid).update({
            'role': role,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Role assigned successfully')),
          );

          // Navigate based on the assigned role
          switch (role) {
            case 'agency':
              Navigator.pushReplacementNamed(context, '/createagency');
              break;
            case 'sponsors':
              Navigator.pushReplacementNamed(context, '/createsponsors');
              break;
            case 'judge':
              Navigator.pushReplacementNamed(context, '/judgehome');
              break;
            default:
              Navigator.pushReplacementNamed(context, '/home');
              break;
          }
        } else {
          // User already has a role other than 'users'
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You already have a role assigned')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
    }
  } catch (e) {
    print('Error assigning role: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to assign role')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upgrade Your Account', style: TextStyle(color: Colors.grey[300])),
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
        padding: EdgeInsets.all(20),
        color: Colors.grey[900],
        child: GridView.count(
          crossAxisCount: 1, // Adjust the number of columns here
          childAspectRatio: 3, // Adjust the aspect ratio for each card
          mainAxisSpacing: 20,
          children: [
            _buildRoleCard(
              title: 'Agency',
              description: 'Upgrade to Agency role.',
              onPressed: () => _assignRole('agency'),
            ),
            _buildRoleCard(
              title: 'Sponsors',
              description: 'Upgrade to Sponsors role.',
              onPressed: () => _assignRole('sponsors'),
            ),
            _buildRoleCard(
              title: 'Judge',
              description: 'Upgrade to Judge role.',
              onPressed: () => _assignRole('judge'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.grey[850],
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 40,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text('Upgrade to $title'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}