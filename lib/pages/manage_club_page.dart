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
  String? selectedMemberToRemove; // Nullable

  @override
  void initState() {
    super.initState();
    clubData = widget.clubSnapshot.data() as Map<String, dynamic>;
    viceCaptainName = clubData['vice_captain_name'];
    selectedMemberToRemove = null; // Initialize as null
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
                  child: DropdownButtonFormField<String>(
                    value: viceCaptainName,
                    hint: Text('Select Vice Captain'),
                    items: _buildMemberDropdownItems(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          viceCaptainName = value;
                        });
                        _assignViceCaptain(value);
                      }
                    },
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
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMemberToRemove,
                    hint: Text('Select Member to Remove'),
                    items: _buildMemberDropdownItemsForRemoval(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedMemberToRemove = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (selectedMemberToRemove != null) {
                      _removeMember(selectedMemberToRemove!);
                    }
                  },
                  child: Text('Remove Member'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildMemberDropdownItems() {
    List<DropdownMenuItem<String>> items = [];
    List<dynamic> members = clubData['members'];
    String leaderId = clubData['leader'];

    members.forEach((memberId) {
      if (memberId != leaderId) {
        String memberName =
            memberId.toString(); // Ensure memberId is converted to String
        items.add(DropdownMenuItem(
          value: memberName,
          child: Text(memberName),
        ));
      }
    });

    // If there are no members available, add a placeholder item
    if (items.isEmpty) {
      items.add(DropdownMenuItem(
        value: null,
        child: Text('No members available'),
      ));
    }

    return items;
  }

  List<DropdownMenuItem<String>> _buildMemberDropdownItemsForRemoval() {
    List<DropdownMenuItem<String>> items = [];
    List<dynamic> members = clubData['members'];

    members.forEach((memberId) {
      String memberName =
          memberId.toString(); // Ensure memberId is converted to String
      items.add(DropdownMenuItem(
        value: memberName,
        child: Text(memberName),
      ));
    });

    return items;
  }

  Widget _buildMembersList(List<dynamic>? members) {
    if (members == null || members.isEmpty) {
      return Center(child: Text('No members found'));
    }

    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        String memberName =
            members[index].toString(); // Convert memberId to String
        return ListTile(
          title: Text(memberName),
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
      selectedMemberToRemove = null; // Reset selected member after removal
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Member removed successfully')),
    );
  }
}
