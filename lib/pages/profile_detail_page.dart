import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:country_code_picker/country_code_picker.dart';

class ProfileDetailPage extends StatelessWidget {
  final String uid;

  ProfileDetailPage({required this.uid});

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> userDataStream =
        FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Detail'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userDataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No data available'));
          }

          Map<String, dynamic> userData = snapshot.data!.data()!;
          String? imageUrl = userData['profile_picture'];

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl)
                      : AssetImage('assets/default_profile.jpg')
                          as ImageProvider,
                ),
                SizedBox(height: 20),
                buildProfileField('Blader Name', userData['blader_name']),
                buildProfileField('First Name', userData['first_name']),
                buildProfileField('Middle Name', userData['middle_name']),
                buildProfileField('Last Name', userData['last_name']),
                buildProfileField('Age', userData['age']),
                buildDateField('Birthdate', userData['birthdate']),
                buildProfileField('Email', userData['email']),
                buildProfileField('Contact No.', userData['contact_no']),
                buildNationalityField(userData['nationality']),
                SizedBox(height: 20),
                Text(
                  'Clubs Joined',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                buildClubsList(uid),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildProfileField(String label, String? value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value ?? 'Unknown'),
      ),
    );
  }

  Widget buildDateField(String label, String? value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value ?? 'Unknown'),
      ),
    );
  }

  Widget buildNationalityField(String? value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text('Nationality'),
        subtitle: Row(
          children: [
            value != null
                ? Image.asset(
                    'packages/country_code_picker/flags/${value.toLowerCase()}.png',
                    width: 25,
                    height: 25,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Text('Flag not found');
                    },
                  )
                : Container(),
            SizedBox(width: 10),
            Text(value ?? 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget buildClubsList(String userId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchUserClubs(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No clubs joined');
        }

        List<Map<String, dynamic>> clubs = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: clubs.map((club) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(club['name'] ?? 'Unknown Club'),
                subtitle:
                    Text('Leader: ${club['leaderBladerName'] ?? 'Unknown'}'),
                onTap: () {
                  // Navigate to the club details page or perform other actions
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUserClubs(String userId) async {
    QuerySnapshot<Map<String, dynamic>> clubsSnapshot = await FirebaseFirestore
        .instance
        .collection('clubs')
        .where('members', arrayContains: userId)
        .get();

    List<Map<String, dynamic>> clubs = [];

    for (var doc in clubsSnapshot.docs) {
      Map<String, dynamic> clubData = doc.data();
      if (clubData['leader'] != null) {
        DocumentSnapshot<Map<String, dynamic>> leaderSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(clubData['leader'])
                .get();
        if (leaderSnapshot.exists) {
          clubData['leaderBladerName'] =
              leaderSnapshot.data()?['blader_name'] ?? 'Unknown';
        } else {
          clubData['leaderBladerName'] = 'Unknown';
        }
      }
      clubs.add(clubData);
    }
    return clubs;
  }
}
