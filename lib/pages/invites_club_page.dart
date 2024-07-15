import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InviteClubPage extends StatefulWidget {
  @override
  _InviteClubPageState createState() => _InviteClubPageState();
}

class _InviteClubPageState extends State<InviteClubPage> {
  List<Map<String, dynamic>> _clubLeaders = [];
  List<Map<String, dynamic>> _agencies = [];
  String _invitationTitle = 'Invitation to Join Our Club';
  String _invitationDescription =
      'We are excited to invite you to join our club. Here are the details:';
  String _invitationMessage = 'You have been invited to join our club!';

  @override
  void initState() {
    super.initState();
    _fetchClubLeaders();
    _fetchAgencies();
  }

  Future<void> _fetchClubLeaders() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .where('leader', isNotEqualTo: null)
        .get();
    setState(() {
      _clubLeaders = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'club_name': data['name'] ?? 'No Club Name',
          'leader_name': data['leader_name'] ?? '',
          'clubId': doc.id,
        };
      }).toList();
    });
  }

  Future<void> _fetchAgencies() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('agencies').get();
    setState(() {
      _agencies = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'agency_name': data['agency_name'] ?? 'No Agency Name',
          'agency_email': data['agency_email'] ?? '',
          'contact': data['contact'] ?? '',
          'agencyId': doc.id,
        };
      }).toList();
    });
  }

  void _inviteLeader(String leaderName, String clubId, String agencyId,
      String agencyEmail) async {
    try {
      // Get the agency details including the agency email
      DocumentSnapshot agencySnapshot = await FirebaseFirestore.instance
          .collection('agencies')
          .doc(agencyId)
          .get();

      if (agencySnapshot.exists) {
        // Query Firestore to get the user document based on leader_name
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('blader_name', isEqualTo: leaderName)
            .get();

        if (userSnapshot.docs.isEmpty) {
          print('User with leader_name $leaderName not found in Firestore.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('User with leader_name $leaderName not found.')),
          );
          return;
        }

        // Assuming there's only one document per leader_name, so accessing the first one
        DocumentSnapshot userDoc = userSnapshot.docs.first;
        String leaderEmail = userDoc['email'];

        // Validate email format using a regex pattern
        bool isValidEmail =
            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(leaderEmail);

        if (!isValidEmail) {
          print('Invalid leader email address');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid leader email address')),
          );
          return;
        }

        // Check if there's already an existing invitation
        QuerySnapshot existingInvitations = await FirebaseFirestore.instance
            .collection('invitations')
            .where('recipientId', isEqualTo: userDoc.id)
            .where('agencyId', isEqualTo: agencyId)
            .get();

        if (existingInvitations.docs.isEmpty) {
          // Create a new invitation document
          await FirebaseFirestore.instance.collection('invitations').add({
            'recipientId': userDoc.id,
            'agencyId': agencyId,
            'agencyEmail': agencySnapshot['agency_email'],
            'agencyName': agencySnapshot['agency_name'],
            'invitationTitle': _invitationTitle,
            'invitationDescription': _invitationDescription,
            'invitationMessage': _invitationMessage,
            'createdAt': FieldValue.serverTimestamp(),
          });

          print('Invitation stored successfully.');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Invitation sent to $leaderEmail from ${agencySnapshot['agency_name']} and stored.'),
            ),
          );
        } else {
          print('User already invited by this agency');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User already invited by this agency')),
          );
        }
      } else {
        print('Agency not found');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected agency not found')),
        );
      }
    } catch (e, stackTrace) {
      print('Error inviting leader: $e\n$stackTrace'); // Print detailed error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inviting leader')), // Show error message
      );
    }
  }

  Future<void> _editInvitationMessage() async {
    TextEditingController titleController =
        TextEditingController(text: _invitationTitle);
    TextEditingController descriptionController =
        TextEditingController(text: _invitationDescription);
    TextEditingController messageController =
        TextEditingController(text: _invitationMessage);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Invitation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _invitationTitle = titleController.text;
                  _invitationDescription = descriptionController.text;
                  _invitationMessage = messageController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Club Leaders'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editInvitationMessage,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _clubLeaders.length,
        itemBuilder: (context, index) {
          final club = _clubLeaders[index];
          return ListTile(
            title: Text(club['club_name']),
            subtitle: Text(club['leader_name']),
            trailing: PopupMenuButton(
              itemBuilder: (context) => _buildPopupMenuItems(club['clubId']),
              onSelected: (String agencyId) {
                _inviteLeader(club['leader_name'], club['clubId'], agencyId,
                    _findAgencyEmailById(agencyId));
              },
              icon: Icon(Icons.mail),
            ),
          );
        },
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(String clubId) {
    return _agencies.map((agency) {
      return PopupMenuItem<String>(
        value: agency['agencyId'],
        child: Text(agency['agency_name']),
      );
    }).toList();
  }

  String _findAgencyEmailById(String agencyId) {
    var agency = _agencies.firstWhere(
        (element) => element['agencyId'] == agencyId,
        orElse: () => null);
    return agency != null ? agency['agency_email'] : '';
  }
}
