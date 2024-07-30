import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:beyblade/pages/bracket_screen.dart'; // Ensure this import is included

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
          .map((doc) => doc.id.replaceFirst('${tournamentDoc.id}_',
              '')) // Extract blader_name from document ID
          .toList();
    } catch (error) {
      print('Error fetching participants: $error');
    }
    return participants;
  }

  Future<void> _updateParticipantsInFirestore(BuildContext context) async {
    try {
      final participants = await _fetchParticipantsFromChallonge();

      for (var participant in participants) {
        final displayName = participant['display_name'];
        final PID = participant['id'];
        final participantId = '${tournamentDoc.id}_$displayName';

        await FirebaseFirestore.instance
            .collection('participants')
            .doc(participantId)
            .update({
          'id': participantId,
          'display_name': displayName,
          'Pid': PID,
          // Include other fields if necessary
        }).catchError((error) {
          print('Error updating document $participantId: $error');
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Participants updated successfully')),
      );
    } catch (e) {
      print('Error updating participants: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating participants')),
      );
    }
  }

  Future<void> _endTournament(BuildContext context) async {
    try {
      // Update participants in Firestore
      await _updateParticipantsInFirestore(context);

      // Fetch match details and record participant stats
      await _recordParticipantStats(context);

      // Update the tournament status to 'ended'
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

  Future<List<Map<String, dynamic>>> _fetchParticipantsFromChallonge() async {
    final response = await http.get(Uri.parse(
        'http://localhost:3000/tournament/${tournamentDoc.id}/participants'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => item['participant'] as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception('Failed to load participants from Challonge');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMatchDetails() async {
    final response = await http.get(Uri.parse(
        'http://localhost:3000/tournament/${tournamentDoc.id}/matches'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item['match'] as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load match details');
    }
  }

  Future<void> _recordParticipantStats(BuildContext context) async {
    try {
      // Fetch match details
      final matchDetails = await _fetchMatchDetails();

      // Fetch all participant documents for the tournament
      final participantsSnapshot = await FirebaseFirestore.instance
          .collection('participants')
          .where('tournament_id', isEqualTo: tournamentDoc.id)
          .get();

      // Map Pid to document ID, handle missing Pid
      final participantsMap = Map.fromIterable(participantsSnapshot.docs,
          key: (doc) =>
              doc.data().containsKey('Pid') ? doc.data()['Pid'] : null,
          value: (doc) => doc.id)
        ..removeWhere(
            (key, value) => key == null); // Remove entries with null Pid

      // Create a map to track participant stats
      final participantStats = <String, Map<String, dynamic>>{};

      for (var match in matchDetails) {
        final player1Id = match['player1_id'] as int;
        final player2Id = match['player2_id'] as int;
        final winnerId = match['winner_id'] as int;
        final scoresCsv = match['scores_csv'] as String;

        final player1DocId = participantsMap[player1Id];
        final player2DocId = participantsMap[player2Id];

        // Initialize player stats if not already
        if (player1DocId != null &&
            !participantStats.containsKey(player1DocId)) {
          participantStats[player1DocId] = {
            'id': player1Id,
            'wins': 0,
            'losses': 0,
            'total_scores': 0,
            'total_losses': 0
          };
        }
        if (player2DocId != null &&
            !participantStats.containsKey(player2DocId)) {
          participantStats[player2DocId] = {
            'id': player2Id,
            'wins': 0,
            'losses': 0,
            'total_scores': 0,
            'total_losses': 0
          };
        }

        // Update stats based on match results
        if (winnerId == player1Id) {
          if (player1DocId != null) {
            participantStats[player1DocId]!['wins'] =
                (participantStats[player1DocId]!['wins'] as int) + 1;
          }
          if (player2DocId != null) {
            participantStats[player2DocId]!['losses'] =
                (participantStats[player2DocId]!['losses'] as int) + 1;
          }
        } else if (winnerId == player2Id) {
          if (player2DocId != null) {
            participantStats[player2DocId]!['wins'] =
                (participantStats[player2DocId]!['wins'] as int) + 1;
          }
          if (player1DocId != null) {
            participantStats[player1DocId]!['losses'] =
                (participantStats[player1DocId]!['losses'] as int) + 1;
          }
        }

        // Update total scores
        final scores = scoresCsv.split('-');
        if (scores.length == 2) {
          if (player1DocId != null) {
            participantStats[player1DocId]!['total_scores'] =
                (participantStats[player1DocId]!['total_scores'] as int) +
                    int.parse(scores[0]);
          }
          if (player2DocId != null) {
            participantStats[player2DocId]!['total_scores'] =
                (participantStats[player2DocId]!['total_scores'] as int) +
                    int.parse(scores[1]);
          }
        }
      }

      // Save participant stats to Firestore
      final batch = FirebaseFirestore.instance.batch();
      for (var docId in participantStats.keys) {
        final stats = participantStats[docId]!;
        final docRef =
            FirebaseFirestore.instance.collection('participants').doc(docId);
        batch.update(docRef, stats);
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Participant stats recorded successfully')),
      );
    } catch (e) {
      print('Error recording participant stats: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording participant stats')),
      );
    }
  }
}
