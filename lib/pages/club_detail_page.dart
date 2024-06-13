import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubDetailPage extends StatelessWidget {
  final Map<String, dynamic> clubData;

  const ClubDetailPage({required this.clubData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clubData['name']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: _fetchBladerName(clubData['leader']),
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Leader: Loading...');
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text('Leader: Unknown');
                }
                return Text('Leader: ${snapshot.data}');
              },
            ),
            SizedBox(height: 8),
            Text('Members:'),
            Expanded(
              child: ListView.builder(
                itemCount: clubData['members'].length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                    future: _fetchBladerName(clubData['members'][index]),
                    builder: (context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Loading...'),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return ListTile(
                          title: Text('Unknown'),
                        );
                      }
                      return ListTile(
                        title: Text(snapshot.data!),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
