import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageClubPage extends StatefulWidget {
  final DocumentSnapshot clubSnapshot;

  ManageClubPage({required this.clubSnapshot});

  @override
  _ManageClubPageState createState() => _ManageClubPageState();
}

class _ManageClubPageState extends State<ManageClubPage> {
  late Map<String, dynamic> clubData;
  String? viceCaptainName;

  @override
  void initState() {
    super.initState();
    clubData = widget.clubSnapshot.data() as Map<String, dynamic>;
    viceCaptainName = clubData['vice_captain_name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Club'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Club Name: ${clubData['name'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Leader: ${clubData['leader_name'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showAssignViceCaptainBottomSheet(context);
                    },
                    child: Text('Assign Vice Captain'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Members:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _buildMembersList(clubData['members']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(List<dynamic>? members) {
    if (members == null || members.isEmpty) {
      return Center(child: Text('No members found'));
    }

    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        String memberId = members[index].toString();
        return FutureBuilder<DocumentSnapshot>(
          future: _fetchMemberData(memberId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return ListTile(
                title: Text(
                    'Member ID: $memberId'), // Fallback if data fetch fails
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showRemoveMemberDialog(memberId);
                  },
                ),
              );
            }
            var memberData = snapshot.data!.data() as Map<String, dynamic>;
            String bladerName = memberData['blader_name'] ?? 'Unknown';
            return ListTile(
              title: Text(bladerName),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showRemoveMemberDialog(memberId);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<DocumentSnapshot> _fetchMemberData(String memberId) {
    return FirebaseFirestore.instance.collection('users').doc(memberId).get();
  }

  void _showAssignViceCaptainBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Vice Captain',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: clubData['members'].length,
                    itemBuilder: (context, index) {
                      String memberId = clubData['members'][index].toString();
                      return ListTile(
                        title: FutureBuilder<DocumentSnapshot>(
                          future: _fetchMemberData(memberId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return Text(
                                  'Member ID: $memberId'); // Fallback if data fetch fails
                            }
                            var memberData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            String bladerName =
                                memberData['blader_name'] ?? 'Unknown';
                            return Text(bladerName);
                          },
                        ),
                        onTap: () {
                          _assignViceCaptain(memberId);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRemoveMemberDialog(String memberId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Member'),
          content: Text('Are you sure you want to remove this member?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _removeMember(memberId);
                Navigator.pop(context);
              },
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _assignViceCaptain(String memberId) async {
    await widget.clubSnapshot.reference.update({
      'vice_captain_name': memberId,
    });
    setState(() {
      viceCaptainName = memberId;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vice Captain assigned successfully')),
    );
  }

  Future<void> _removeMember(String memberId) async {
    await widget.clubSnapshot.reference.update({
      'members': FieldValue.arrayRemove([memberId]),
    });
    setState(() {
      clubData['members'].remove(memberId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Member removed successfully')),
    );
  }
}
