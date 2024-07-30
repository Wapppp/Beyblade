import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RankingScreen extends StatefulWidget {
  final String tournamentId;

  const RankingScreen({Key? key, required this.tournamentId}) : super(key: key);

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<Map<String, dynamic>> participants = [];
  bool isLoadingData = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRankingData(widget.tournamentId);
  }

  Future<void> fetchRankingData(String tournamentId) async {
    setState(() {
      isLoadingData = true;
    });

    try {
      final participantsResponse = await http.get(
        Uri.parse(
            'http://localhost:3000/tournament/$tournamentId/participants'),
      );

      final matchesResponse = await http.get(
        Uri.parse('http://localhost:3000/tournament/$tournamentId/matches'),
      );

      if (participantsResponse.statusCode == 200 &&
          matchesResponse.statusCode == 200) {
        final participantsData = jsonDecode(participantsResponse.body) as List;
        final matchesData = jsonDecode(matchesResponse.body) as List;

        // Initialize participant stats
        final Map<String, Map<String, dynamic>> participantMap = {};
        for (var entry in participantsData) {
          final p = entry['participant'];
          if (p != null) {
            participantMap[p['id'].toString()] = {
              'id': p['id'].toString(),
              'name': p['name'],
              'wins': 0,
              'losses': 0,
              'draws': 0,
              'points': 0,
            };
          }
        }

        // Process matches data
        for (var match in matchesData) {
          final m = match['match'];
          if (m != null && m['state'] == 'complete') {
            final player1Id = m['player1_id'].toString();
            final player2Id = m['player2_id'].toString();
            final scoresCsv =
                m['scores_csv'] ?? '0-0'; // Default to '0-0' if null
            final scores =
                scoresCsv.split('-').map((s) => int.tryParse(s) ?? 0).toList();

            if (scores.length == 2) {
              if (scores[0] > scores[1]) {
                participantMap[player1Id]!['wins'] += 1;
                participantMap[player2Id]!['losses'] += 1;
                participantMap[player1Id]!['points'] += 3; // 3 points for a win
              } else if (scores[0] < scores[1]) {
                participantMap[player2Id]!['wins'] += 1;
                participantMap[player1Id]!['losses'] += 1;
                participantMap[player2Id]!['points'] += 3; // 3 points for a win
              } else {
                participantMap[player1Id]!['draws'] += 1;
                participantMap[player2Id]!['draws'] += 1;
                participantMap[player1Id]!['points'] += 1; // 1 point for a draw
                participantMap[player2Id]!['points'] += 1;
              }
            }
          }
        }

        // Convert the map to a list and sort rankings
        final sortedParticipants = participantMap.values.toList()
          ..sort((a, b) => b['points'].compareTo(a['points']));

        setState(() {
          participants = sortedParticipants;
          isLoadingData = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error fetching ranking data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching ranking data')),
      );
      setState(() {
        isLoadingData = false;
      });
    }
  }

  Map<String, Map<String, dynamic>> _initializeParticipantMap(
      List participantsData) {
    final Map<String, Map<String, dynamic>> participantMap = {};
    for (var entry in participantsData) {
      final p = entry['participant'];
      if (p != null) {
        participantMap[p['id'].toString()] = {
          'id': p['id'].toString(),
          'name': p['name'],
          'wins': 0,
          'losses': 0,
          'draws': 0,
          'points': 0.0, // Initialize points as double
        };
      }
    }
    return participantMap;
  }

  void _processMatchesData(
      List matchesData, Map<String, Map<String, dynamic>> participantMap) {
    for (var match in matchesData) {
      if (match['state'] == 'complete') {
        final player1Id = match['player1_id'].toString();
        final player2Id = match['player2_id'].toString();
        final scoresCsv = match['scores_csv'] ?? '0-0';
        final scores =
            scoresCsv.split('-').map((s) => int.tryParse(s) ?? 0).toList();

        if (scores.length == 2) {
          if (scores[0] > scores[1]) {
            // Player 1 wins
            participantMap[player1Id]!['wins'] += 1;
            participantMap[player2Id]!['losses'] += 1;
            participantMap[player1Id]!['points'] += 1.0; // 1.0 point for a win
          } else if (scores[0] < scores[1]) {
            // Player 2 wins
            participantMap[player2Id]!['wins'] += 1;
            participantMap[player1Id]!['losses'] += 1;
            participantMap[player2Id]!['points'] += 1.0; // 1.0 point for a win
          } else {
            // Draw
            participantMap[player1Id]!['draws'] += 1;
            participantMap[player2Id]!['draws'] += 1;
            participantMap[player1Id]!['points'] +=
                0.5; // 0.5 points for a draw
            participantMap[player2Id]!['points'] +=
                0.5; // 0.5 points for a draw
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Rankings'),
      ),
      body: isLoadingData
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text('Error: $errorMessage'))
              : ListView.builder(
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return ListTile(
                      title: Text(participant['name']),
                      subtitle: Text('Rank: ${index + 1}'),
                      trailing: Text('Points: ${participant['points']}'),
                      onTap: () => showDetails(context, participant),
                    );
                  },
                ),
    );
  }

  void showDetails(BuildContext context, Map<String, dynamic> participant) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(participant['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rank: ${participants.indexOf(participant) + 1}'),
              Text('Points: ${participant['points']}'),
              Text('Wins: ${participant['wins']}'),
              Text('Losses: ${participant['losses']}'),
              Text('Draws: ${participant['draws']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
