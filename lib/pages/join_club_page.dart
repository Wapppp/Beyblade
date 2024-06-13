import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beyblade/pages/club_detail_page.dart'; // Adjust the import as per your project structure

class JoinClubPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join a Club'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No clubs available'));
          }

          List<QueryDocumentSnapshot> clubs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              var clubData = clubs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(clubData['name']),
                subtitle: FutureBuilder<String>(
                  future: _fetchBladerName(clubData['leader']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text('Leader: Unknown');
                    }
                    return Text('Leader: ${snapshot.data}');
                  },
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClubDetailPage(clubData: clubData),
                      ),
                    );
                  },
                  child: Text('View'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String> _fetchBladerName(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    return userSnapshot.exists
        ? userSnapshot.data()!['blader_name'] ?? 'Unknown'
        : 'Unknown';
  }
}
