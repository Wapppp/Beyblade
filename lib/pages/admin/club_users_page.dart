import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define the color palette for the app
class AppColors {
  static const Color primaryColor = Colors.orange;
  static const Color accentColor = Colors.amber;
  static const Color appBarColor = Colors.black;
  static const Color scaffoldBackgroundColor = Colors.grey;
  static const Color cardColor = Color.fromARGB(255, 39, 39, 39);
}

class ClubUsersPage extends StatelessWidget {
  final String clubId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ClubUsersPage({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Users'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[900], // Set background color to grey 900
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('clubs').doc(clubId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
                child: Text('Club not found.',
                    style: TextStyle(color: Colors.white)));
          }

          var clubData = snapshot.data!.data() as Map<String, dynamic>;
          var clubName = clubData['name'] ?? 'Unnamed Club';
          var leaderName = clubData['leader_name'] ?? 'Unknown';
          var membersIds = List<String>.from(clubData['members'] ?? []);

          if (membersIds.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Club: $clubName',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Leader: $leaderName',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    SizedBox(height: 16),
                    Text('No members found.',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ],
                ),
              ),
            );
          }

          var membersQuery = _firestore.collection('users').where(
                FieldPath.documentId,
                whereIn: membersIds,
              );

          return FutureBuilder<QuerySnapshot>(
            future: membersQuery.get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                return Center(
                    child: Text('Error: ${userSnapshot.error}',
                        style: TextStyle(color: Colors.white)));
              }

              var membersList = userSnapshot.data!.docs;

              return ListView.builder(
                itemCount: membersList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 41, 41, 41),
                            Color.fromARGB(255, 53, 53, 53)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Club: $clubName',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Leader: $leaderName',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white70),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Members',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }

                  var member = membersList[index - 1];
                  var bladerName = member['blader_name'] ?? 'Unnamed Member';
                  var email = member['email'] ?? 'No Email';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    elevation: 2,
                    color: AppColors.cardColor,
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      leading: CircleAvatar(
                        child:
                            Text((index).toString()), // Numbering each member
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      title: Text(
                        bladerName,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Text(email,
                          style:
                              TextStyle(fontSize: 14, color: Colors.white70)),
                      onTap: () {
                        // Handle tapping on a member if needed
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
