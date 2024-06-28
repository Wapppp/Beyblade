import 'package:flutter/material.dart';
import 'user_profile.dart';

class UserProfile {
  final String bladerName;
  final int won;
  final int lost;
  final String profilePicture;

  UserProfile({
    required this.bladerName,
    required this.won,
    required this.lost,
    required this.profilePicture,
  });
}

class UserProfilePage extends StatelessWidget {
  final UserProfile userProfile;

  const UserProfilePage({Key? key, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userProfile.bladerName),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(userProfile.profilePicture),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blader Name',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    userProfile.bladerName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Performance',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPerformanceItem('Won', userProfile.won.toString()),
                      _buildPerformanceItem('Lost', userProfile.lost.toString()),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Other Details',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  // Add more details as needed
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900], // Dark background color
    );
  }

  Widget _buildPerformanceItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}