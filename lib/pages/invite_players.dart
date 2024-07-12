import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvitePlayersPage extends StatefulWidget {
  @override
  _InvitePlayersPageState createState() => _InvitePlayersPageState();
}

class _InvitePlayersPageState extends State<InvitePlayersPage> {
  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> _agencies = [];
  String _invitationTitle = 'Invitation to Join Our Agency';
  String _invitationDescription = 'We are excited to invite you to join our agency. Here are the details:';
  String _invitationMessage = 'You have been invited to join our agency!';

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
    _fetchAgencies();
  }

  Future<void> _fetchPlayers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _players = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'blader_name': data['blader_name'] ?? 'No Name',
          'email': data['email'] ?? '',
          'userId': doc.id,
        };
      }).toList();
    });
  }

  Future<void> _fetchAgencies() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('agencies').get();
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

  void _invitePlayer(String email, String userId, String agencyId, String agencyEmail) async {
    if (email.isNotEmpty) {
      DocumentSnapshot agencySnapshot = await FirebaseFirestore.instance.collection('agencies').doc(agencyId).get();

      if (agencySnapshot.exists) {
        QuerySnapshot existingInvitations = await FirebaseFirestore.instance
            .collection('invitations')
            .where('recipientId', isEqualTo: userId)
            .where('agencyEmail', isEqualTo: agencyEmail)
            .get();

        if (existingInvitations.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('invitations').add({
            'recipientId': userId,
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

          print('Invited player: $email');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invitation sent to $email from ${agencySnapshot['agency_name']}')),
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
    } else {
      print('Invalid email address');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email address')),
      );
    }
  }

  Future<void> _editInvitationMessage() async {
    TextEditingController titleController = TextEditingController(text: _invitationTitle);
    TextEditingController descriptionController = TextEditingController(text: _invitationDescription);
    TextEditingController messageController = TextEditingController(text: _invitationMessage);

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
        title: Text('Invite Players'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editInvitationMessage,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _players.length,
        itemBuilder: (context, index) {
          final player = _players[index];
          return ListTile(
            title: Text(player['blader_name']),
            subtitle: Text(player['email']),
            trailing: PopupMenuButton(
              itemBuilder: (context) => _buildPopupMenuItems(player['userId']),
              onSelected: (String agencyId) {
                _invitePlayer(player['email'], player['userId'], agencyId, 'agencyEmail');
              },
              icon: Icon(Icons.mail),
            ),
          );
        },
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(String userId) {
    return _agencies.map((agency) {
      return PopupMenuItem<String>(
        value: agency['agencyId'],
        child: Text(agency['agency_name']),
      );
    }).toList();
  }
}