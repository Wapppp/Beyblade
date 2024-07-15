import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String bladerName;
  final int won;
  final int lost;
  final String profilePicture;
  final String bio; // New field for bio

  UserProfile({
    required this.bladerName,
    required this.won,
    required this.lost,
    required this.profilePicture,
    required this.bio,
  });
}

class UserProfilePage extends StatelessWidget {
  final String bladerName; // Blader name to fetch data from Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserProfilePage({Key? key, required this.bladerName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserData(),
      builder: (context, AsyncSnapshot<UserProfile> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          print('Error fetching user data: ${snapshot.error}');
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
            ),
            body: Center(
              child: Text('Failed to load user data'),
            ),
          );
        }

        var userProfile = snapshot.data!;

        return _buildUserProfile(userProfile);
      },
    );
  }

  Future<UserProfile> _fetchUserData() async {
    try {
      final userSnapshot = await _firestore
          .collection('users')
          .where('blader_name', isEqualTo: bladerName)
          .get();

      final playerStatsSnapshot = await _firestore
          .collection('playerstats')
          .where('blader_name', isEqualTo: bladerName)
          .get();

      if (userSnapshot.docs.isEmpty || playerStatsSnapshot.docs.isEmpty) {
        throw 'User data not found for blader_name: $bladerName';
      }

      var userData = userSnapshot.docs.first.data();
      var statsData = playerStatsSnapshot.docs.first.data();

      return UserProfile(
        bladerName: bladerName,
        won: statsData['total_wins'] ?? 0,
        lost: statsData['total_losses'] ?? 0,
        profilePicture: userData['profile_picture'] ?? '',
        bio: userData['bio'] ?? '', // Fetching bio from Firestore
      );
    } catch (e) {
      print('Error fetching user data: $e');
      throw e;
    }
  }

  Widget _buildUserProfile(UserProfile userProfile) {
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
          crossAxisAlignment: CrossAxisAlignment.center, // Align center horizontally
          children: [
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: userProfile.profilePicture.isNotEmpty
                    ? NetworkImage(userProfile.profilePicture)
                    : AssetImage('assets/default_profile_picture.png'),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Align center horizontally
                children: [
                  Text(
                    'Blader Name',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center, // Center align text
                  ),
                  Text(
                    userProfile.bladerName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center, // Center align text
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Bio', // Displaying Bio section
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center, // Center align text
                  ),
                  SizedBox(height: 10),
                  Text(
                    userProfile.bio,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center, // Center align text
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Stats',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center, // Center align text
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Center align row items
                    children: [
                      _buildPerformanceItem('Won', userProfile.won.toString()),
                      _buildPerformanceItem('Lost', userProfile.lost.toString()),
                    ],
                  ),
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