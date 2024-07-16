import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InviteClubLeadersPage extends StatefulWidget {
  @override
  _InviteClubLeadersPageState createState() => _InviteClubLeadersPageState();
}

class _InviteClubLeadersPageState extends State<InviteClubLeadersPage> {
  List<Map<String, dynamic>> _clubLeaders = [];
  List<Map<String, dynamic>> _agencies = [];
  String _invitationTitle = 'Invitation to Join Our Agency';
  String _invitationDescription =
      'We are excited to invite you to join our agency. Here are the details:';
  String _invitationMessage = 'You have been invited to join our agency!';

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
          'email': data['leader_email'] ?? '',
          'clubId': doc.id,
          'leaderId': data['leader'] ?? '',
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

  void _inviteClubLeader(String leaderId, String clubId, String agencyId) async {
    DocumentSnapshot agencySnapshot = await FirebaseFirestore.instance
        .collection('agencies')
        .doc(agencyId)
        .get();

    if (agencySnapshot.exists) {
      QuerySnapshot existingInvitations = await FirebaseFirestore.instance
          .collection('inviteclubs')
          .where('recipientId', isEqualTo: leaderId)
          .where('agencyId', isEqualTo: agencyId)
          .get();

      if (existingInvitations.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('inviteclubs').add({
          'recipientId': leaderId,
          'agencyId': agencyId,
          'agencyEmail': agencySnapshot['agency_email'],
          'agencyName': agencySnapshot['agency_name'],
          'invitationTitle': _invitationTitle,
          'invitationDescription': _invitationDescription,
          'invitationMessage': _invitationMessage,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Send the email (this part needs a backend service to handle the email sending)
        // For example, using Firebase Functions or any other email service.

        print('Invited club leader with ID: $leaderId');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Invitation sent to ${leaderId} from ${agencySnapshot['agency_name']}')),
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
          final clubLeader = _clubLeaders[index];
          return ListTile(
            title: Text(clubLeader['club_name']),
            subtitle: Text(clubLeader['leader_name']),
            trailing: PopupMenuButton(
              itemBuilder: (context) =>
                  _buildPopupMenuItems(clubLeader['clubId']),
              onSelected: (String agencyId) {
                _inviteClubLeader(clubLeader['leaderId'], clubLeader['clubId'],
                    agencyId);
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
}