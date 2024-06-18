import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClubDetailPage extends StatelessWidget {
  final Map<String, dynamic> clubData;
  final String userId;

  ClubDetailPage({required this.clubData, required this.userId});

  @override
  Widget build(BuildContext context) {
    bool isLeader = clubData['leader'] == userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(clubData['name']),
        actions: isLeader
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteClub(context),
                )
              ]
            : null,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Leader'),
            subtitle: FutureBuilder<String>(
              future: _fetchBladerName(clubData['leader']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text('Unknown');
                }
                return Text(snapshot.data!);
              },
            ),
          ),
          ListTile(
            title: Text('Vice-Captain'),
            subtitle: FutureBuilder<String>(
              future: _fetchBladerName(clubData['vice_captain']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text('No vice-captain assigned');
                }
                return Text(snapshot.data!);
              },
            ),
            trailing: isLeader
                ? IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _assignViceCaptain(context),
                  )
                : null,
          ),
          ListTile(
            title: Text('Members'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (clubData['members'] as List<dynamic>)
                  .map((memberId) => FutureBuilder<String>(
                        future: _fetchBladerName(memberId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Loading...');
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return Text('Unknown');
                          }
                          return ListTile(
                            title: Text(snapshot.data!),
                            trailing: isLeader && memberId != userId
                                ? IconButton(
                                    icon: Icon(Icons.remove_circle),
                                    onPressed: () => _removeMember(memberId),
                                  )
                                : null,
                          );
                        },
                      ))
                  .toList(),
            ),
          ),
          if (!isLeader)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _leaveClub(context),
                child: Text('Leave Club'),
              ),
            ),
        ],
      ),
    );
  }

  Future<String> _fetchBladerName(String uid) async {
    if (uid == null) return 'No vice-captain assigned';
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    return userSnapshot.exists
        ? userSnapshot.data()!['blader_name'] ?? 'Unknown'
        : 'Unknown';
  }

  void _removeMember(String memberId) {
    FirebaseFirestore.instance.collection('clubs').doc(clubData['id']).update({
      'members': FieldValue.arrayRemove([memberId])
    });
  }

  void _deleteClub(BuildContext context) {
    FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubData['id'])
        .delete()
        .then((_) {
      Navigator.pop(context);
    });
  }

  void _assignViceCaptain(BuildContext context) async {
    String? selectedMember;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Assign Vice-Captain'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                isExpanded: true,
                value: selectedMember,
                hint: Text('Select a member'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMember = newValue;
                  });
                },
                items: (clubData['members'] as List<dynamic>)
                    .map<DropdownMenuItem<String>>((memberId) {
                  return DropdownMenuItem<String>(
                    value: memberId,
                    child: FutureBuilder<String>(
                      future: _fetchBladerName(memberId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading...');
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text('Unknown');
                        }
                        return Text(snapshot.data!);
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Assign'),
              onPressed: () {
                if (selectedMember != null) {
                  FirebaseFirestore.instance
                      .collection('clubs')
                      .doc(clubData['id'])
                      .update({
                    'vice_captain': selectedMember,
                  }).then((_) {
                    Navigator.of(context).pop();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _leaveClub(BuildContext context) {
    FirebaseFirestore.instance.collection('clubs').doc(clubData['id']).update({
      'members': FieldValue.arrayRemove([userId])
    }).then((_) {
      Navigator.pop(context);
    });
  }
}
