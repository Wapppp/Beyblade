import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bracket_screen.dart'; // Import the BracketScreen

class TournamentDetailsScreen extends StatelessWidget {
  final DocumentSnapshot tournamentDoc;

  const TournamentDetailsScreen({Key? key, required this.tournamentDoc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournament Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('organizers')
            .doc(tournamentDoc['organizerId'])
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Organizer not found'));
          }

          final organizerName = snapshot.data!['organizer_name'];

          // Convert Firestore Timestamp to DateTime
          Timestamp timestamp = tournamentDoc['event_date_time'];
          DateTime eventDateTime = timestamp.toDate();

          // Format the DateTime using DateFormat
          String formattedDate =
              DateFormat.yMMMMd().add_jm().format(eventDateTime);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BracketScreen(tournamentId: tournamentDoc.id),
                      ),
                    );
                  },
                  child: Text('View Bracket'),
                ),
                Text(
                  tournamentDoc['name'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Organizer: $organizerName',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Date: $formattedDate',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Location: ${tournamentDoc['location']}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Description: ${tournamentDoc['description']}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Confirmed Participants:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('participants')
                        .where('tournament_id', isEqualTo: tournamentDoc.id)
                        .where('status', isEqualTo: 'confirmed') // Filter for confirmed participants
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No confirmed participants yet.'));
                      }

                      final participants = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          var participantData = participants[index].data()
                              as Map<String, dynamic>;
                          return ListTile(
                            title: Text(
                                participantData['blader_name'] ?? 'Unknown'),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _createBracket(context);
                  },
                  child: Text('Add Participants to Bracket'),
                ),
                SizedBox(height: 20),
                _buildQrCodeContainer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrCodeContainer() {
    return FutureBuilder<String>(
      future: _getQrCodeUrl(tournamentDoc.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 200,
            height: 200,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Container(
            width: 200,
            height: 200,
            color: Colors.grey[300],
            child: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }
        final qrCodeUrl = snapshot.data!;
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(qrCodeUrl),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Future<String> _getQrCodeUrl(String eventId) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('qr_codes/$eventId.png');
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _createBracket(BuildContext context) async {
    // Fetch confirmed participants
    List<String> confirmedParticipants = await _fetchConfirmedParticipants();

    // Get the existing tournament ID from your data source
    int tournamentId = tournamentDoc['challongeId'];

    // Add participants to the existing tournament
    await _addParticipantsToTournament(tournamentId, confirmedParticipants);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Participants added to bracket successfully')),
    );
  }

  Future<List<String>> _fetchConfirmedParticipants() async {
    List<String> participants = [];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('participants')
          .where('tournament_id', isEqualTo: tournamentDoc.id)
          .where('status', isEqualTo: 'confirmed')
          .get();

      participants = snapshot.docs
          .map((doc) => doc['blader_name'] as String) // Explicitly cast to String
          .toList();
    } catch (error) {
      print('Error fetching participants: $error');
    }
    return participants;
  }

  Future<void> _addParticipantsToTournament(int tournamentId, List<String> participants) async {
    for (String participant in participants) {
      String apiUrl = 'http://localhost:3000/add-player'; // Proxy server URL for adding players

      try {
        final response = await http.post(Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'tournament_id': tournamentId,
              'participant': {
                'name': participant,
              }
            }));

        if (response.statusCode == 200) {
          print('Participant added: $participant');
        } else {
          print('Failed to add participant: ${response.statusCode}');
        }
      } catch (e) {
        print('Error adding participant: $e');
      }
    }
  }
}
