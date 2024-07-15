import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TournamentDetailsPage extends StatefulWidget {
  final TournamentEvent tournament;

  TournamentDetailsPage({required this.tournament});

  @override
  _TournamentDetailsPageState createState() => _TournamentDetailsPageState();
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage> {
  bool isParticipant = false;
  String participantId = '';
  late User? currentUser;
  bool isOrganizer = false;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _checkParticipantStatus();
      _checkOrganizerStatus();
    }
  }

  void _checkParticipantStatus() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('participants')
          .where('tournament_id', isEqualTo: widget.tournament.id)
          .where('user_id', isEqualTo: currentUser!.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          isParticipant = true;
          participantId = querySnapshot.docs.first.id;
        });
      } else {
        setState(() {
          isParticipant = false;
        });
      }
    } catch (e) {
      print('Error checking participant status: $e');
    }
  }

  void _checkOrganizerStatus() async {
    try {
      DocumentSnapshot organizerDoc = await FirebaseFirestore.instance
          .collection('organizers')
          .doc(currentUser!.uid)
          .get();

      setState(() {
        isOrganizer = organizerDoc.exists;
      });
    } catch (e) {
      print('Error checking organizer status: $e');
    }
  }

  Future<void> _preRegisterTournament(BuildContext context) async {
    if (currentUser == null) {
      return;
    }

    if (isOrganizer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Organizers cannot pre-register for this tournament')),
      );
      return;
    }

    String bladerName = await _fetchBladerName(currentUser!.uid);

    try {
      await FirebaseFirestore.instance.collection('participants').add({
        'tournament_id': widget.tournament.id,
        'user_id': currentUser!.uid,
        'blader_name': bladerName,
        'status': 'not confirmed', // Changed status to not confirmed
      });
      setState(() {
        isParticipant = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pre-registered for Tournament')),
      );
    } catch (e) {
      print('Error pre-registering for tournament: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pre-register for tournament')),
      );
    }
  }

  Future<void> _cancelParticipation(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('participants')
          .doc(participantId)
          .delete();
      setState(() {
        isParticipant = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Canceled Participation')),
      );
    } catch (e) {
      print('Error canceling participation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel participation')),
      );
    }
  }

  Future<String> _fetchBladerName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc['blader_name'];
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return 'Unknown';
    }
  }

  void _onQRViewCreated(String qrCode) async {
    if (currentUser == null) {
      return;
    }

    if (isOrganizer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Organizers cannot confirm participation')),
      );
      return;
    }

    try {
      // Assuming the QR code contains the tournament ID
      String tournamentId = qrCode;

      // Update participant status to confirmed
      await FirebaseFirestore.instance
          .collection('participants')
          .doc(participantId) // Use participantId to update the existing document
          .update({'status': 'confirmed'});

      setState(() {
        isParticipant = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirmed participation')),
      );
    } catch (e) {
      print('Error scanning QR code and confirming participation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm participation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournament Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tournament.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Date: ${_formatTimestamp(widget.tournament.event_date_time)}'),
            SizedBox(height: 8),
            Text('Location: ${widget.tournament.location}'),
            SizedBox(height: 8),
            Text('Description: ${widget.tournament.description}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isOrganizer || isParticipant
                  ? null
                  : () => _preRegisterTournament(context),
              child: Text(isParticipant ? 'Pre-Registered' : 'Pre-Register for Tournament'),
            ),
            if (isParticipant)
              ElevatedButton(
                onPressed: () => _cancelParticipation(context),
                child: Text('Cancel Participation'),
              ),
            SizedBox(height: 16),
            Text(
              'Participants:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildParticipantsList(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScannerPage(onQRViewCreated: _onQRViewCreated),
                ),
              ),
              child: Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('participants')
          .where('tournament_id', isEqualTo: widget.tournament.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No participants yet.'),
          );
        }

        final participants = snapshot.data!.docs.map((doc) {
          String participantId = doc.id;
          return Participant(
            id: participantId,
            userId: doc['user_id'],
            bladerName: doc['blader_name'],
            status: doc['status'], // Get the status of the participant
          );
        }).toList();

        return ListView.builder(
          shrinkWrap: true,
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            return ListTile(
              leading: FutureBuilder<DocumentSnapshot>(
                future: _fetchProfileData(participant.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(
                      child: Text(participant.bladerName[0]),
                    );
                  } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                    return CircleAvatar(
                      child: Text(participant.bladerName[0]),
                    );
                  } else {
                    var profileData = snapshot.data!.data() as Map<String, dynamic>;
                    return CircleAvatar(
                      backgroundImage: NetworkImage(profileData['profile_picture'] ?? ''),
                      child: Text(participant.bladerName[0]),
                    );
                  }
                },
              ),
              title: Text(participant.bladerName),
              subtitle: Text(participant.status), // Display the status of the participant
            );
          },
        );
      },
    );
  }

  Future<DocumentSnapshot> _fetchProfileData(String userId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
    } catch (e) {
      print('Error fetching profile data: $e');
      throw e;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime event_date_time = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(event_date_time);
  }
}

class QRScannerPage extends StatelessWidget {
  final Function(String) onQRViewCreated;

  QRScannerPage({required this.onQRViewCreated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: MobileScanner(
        onDetect: (barcode, args) {
          final String code = barcode.rawValue ?? '';
          onQRViewCreated(code);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class TournamentEvent {
  final String id;
  final String name;
  final Timestamp event_date_time;
  final String location;
  final String description;

  TournamentEvent({
    required this.id,
    required this.name,
    required this.event_date_time,
    required this.location,
    required this.description,
  });
}

class Participant {
  final String id;
  final String userId;
  final String bladerName;
  final String status; // Added status field

  Participant({
    required this.id,
    required this.userId,
    required this.bladerName,
    required this.status,
  });
}
