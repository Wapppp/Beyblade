import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InviteSponsorsPage extends StatefulWidget {
  @override
  _InviteSponsorsPageState createState() => _InviteSponsorsPageState();
}

class _InviteSponsorsPageState extends State<InviteSponsorsPage> {
  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> _sponsors = [];
  String _invitationTitle = 'Invitation to Join Our Sponsor';
  String _invitationDescription =
      'We are excited to invite you to join our sponsor. Here are the details:';
  String _invitationMessage = 'You have been invited to join our sponsor!';

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
    _fetchSponsors();
  }

  Future<void> _fetchPlayers() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
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

  Future<void> _fetchSponsors() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('sponsors').get();
    setState(() {
      _sponsors = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'sponsor_name': data['sponsor_name'] ?? 'No Sponsor Name',
          'sponsor_email': data['sponsor_email'] ?? '',
          'contact': data['contact'] ?? '',
          'sponsorId': doc.id,
        };
      }).toList();
    });
  }

  void _invitePlayer(
      String email, String userId, String sponsorId, String sponsorEmail) async {
    if (email.isNotEmpty) {
      DocumentSnapshot sponsorSnapshot = await FirebaseFirestore.instance
          .collection('sponsors')
          .doc(sponsorId)
          .get();

      if (sponsorSnapshot.exists) {
        QuerySnapshot existingInvitations = await FirebaseFirestore.instance
            .collection('invitesponsors')
            .where('recipientId', isEqualTo: userId)
            .where('sponsorEmail', isEqualTo: sponsorEmail)
            .get();

        if (existingInvitations.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('invitesponsors').add({
            'recipientId': userId,
            'sponsorId': sponsorId,
            'sponsorEmail': sponsorSnapshot['sponsor_email'],
            'sponsorName': sponsorSnapshot['sponsor_name'],
            'invitationTitle': _invitationTitle,
            'invitationDescription': _invitationDescription,
            'invitationMessage': _invitationMessage,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Send the email (this part needs a backend service to handle the email sending)
          // For example, using Firebase Functions or any other email service.

          print('Invited player: $email');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Invitation sent to $email from ${sponsorSnapshot['sponsor_name']}')),
          );
        } else {
          print('User already invited by this sponsor');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User already invited by this sponsor')),
          );
        }
      } else {
        print('Sponsor not found');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected sponsor not found')),
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
        title: Text('Invite Sponsors'),
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
              onSelected: (String sponsorId) {
                _invitePlayer(
                    player['email'], player['userId'], sponsorId, 'sponsorEmail');
              },
              icon: Icon(Icons.mail),
            ),
          );
        },
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(String userId) {
    return _sponsors.map((sponsor) {
      return PopupMenuItem<String>(
        value: sponsor['sponsorId'],
        child: Text(sponsor['sponsor_name']),
      );
    }).toList();
  }
}