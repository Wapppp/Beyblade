import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'manage_participants_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bracket_screen.dart'; // Import the new screen

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
                        builder: (context) =>
                            BracketScreen(tournamentId: tournamentDoc.id),
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
                        .where('status',
                            isEqualTo:
                                'confirmed') // Filter for confirmed participants
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Text('No confirmed participants yet.'));
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
                  child: Text('Create Bracket'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _endTournament(context);
                  },
                  child: Text('End Tournament'),
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

    // Assuming you already have the tournament ID
    String apiUrl =
        'http://localhost:3000/add-player'; // Proxy server URL for adding players

    try {
      for (String participant in confirmedParticipants) {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'tournament_id':
                tournamentDoc.id, // Use the tournament ID from Firestore
            'participant': {
              'name': participant,
            },
          }),
        );

        if (response.statusCode == 200) {
          print('Participant added: $participant');
        } else {
          print('Failed to add participant: ${response.statusCode}');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Participants added successfully')),
      );
    } catch (e) {
      print('Error adding participants: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding participants')),
      );
    }
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
          .map((doc) =>
              doc['blader_name'] as String) // Explicitly cast to String
          .toList();
    } catch (error) {
      print('Error fetching participants: $error');
    }
    return participants;
  }

  Future<void> _endTournament(BuildContext context) async {
    try {
      // Fetch all match details
      final matchDetails = await _fetchMatchDetails();

      // Save match details to Firestore using tournament ID as the document ID
      for (var match in matchDetails) {
        await FirebaseFirestore.instance
            .collection('matches')
            .doc(tournamentDoc.id) // Use tournament ID as document ID
            .set(match); // Save match details
      }

      // Calculate and save participants' stats
      await _recordParticipantStats();

      // Optionally, update tournament status in Firestore
      await FirebaseFirestore.instance
          .collection('tournaments')
          .doc(tournamentDoc.id)
          .update({'status': 'ended'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tournament ended and details saved')),
      );
    } catch (e) {
      print('Error ending tournament: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ending tournament')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMatchDetails() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/tournament/${tournamentDoc.id}/matches'),
    );

    if (response.statusCode == 200) {
      List<dynamic> matches = jsonDecode(response.body);
      return matches.map((match) => match as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load match details');
    }
  }

  Future<void> _recordParticipantStats() async {
    final participantsSnapshot = await FirebaseFirestore.instance
        .collection('participants')
        .where('tournament_id', isEqualTo: tournamentDoc.id)
        .get();

    final participants =
        participantsSnapshot.docs.map((doc) => doc.data()).toList();

    // Create a map to hold participants' stats
    final stats = <String, Map<String, dynamic>>{};

    for (var participant in participants) {
      final name = participant['blader_name'] as String;
      final docId = '${tournamentDoc.id}_$name';
      stats[docId] = {
        'win': 0,
        'lose': 0,
        'score': 0,
      };
    }

    final matchDetails = await _fetchMatchDetails();

    // Calculate stats for each participant
    for (var match in matchDetails) {
      final winnerName = match['winner_name'] as String?;
      final loserName = match['loser_name'] as String?;
      final winnerScore = match['winner_score'] as int? ?? 0;
      final loserScore = match['loser_score'] as int? ?? 0;

      if (winnerName != null) {
        final winnerDocId = '${tournamentDoc.id}_$winnerName';
        if (stats.containsKey(winnerDocId)) {
          stats[winnerDocId]!['win'] += 1;
          stats[winnerDocId]!['score'] += winnerScore;
        }
      }

      if (loserName != null) {
        final loserDocId = '${tournamentDoc.id}_$loserName';
        if (stats.containsKey(loserDocId)) {
          stats[loserDocId]!['lose'] += 1;
          stats[loserDocId]!['score'] += loserScore;
        }
      }
    }

    // Save stats to Firestore
    for (var entry in stats.entries) {
      await FirebaseFirestore.instance
          .collection('participants')
          .doc(entry.key)
          .update(entry.value);
    }
  }
}
