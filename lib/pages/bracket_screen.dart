import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const double _matchHeight = 120;
const double _matchWidth = 240;
const double _matchRightPadding = 20;
const double _minMargin = 10;

class BracketScreen extends StatefulWidget {
  final String tournamentId;

  const BracketScreen({Key? key, required this.tournamentId}) : super(key: key);

  @override
  _BracketScreenState createState() => _BracketScreenState();
}

class _BracketScreenState extends State<BracketScreen> {
  List<dynamic> participants = [];
  List<dynamic> matches = [];
  bool isLoadingData = false;
  List<int> maxRounds = [];

  @override
  void initState() {
    super.initState();
    fetchTournamentData(widget.tournamentId);
  }

  Future<void> fetchTournamentData(String tournamentId) async {
    setState(() {
      isLoadingData = true;
    });

    try {
      final participantsResponse = await http.get(
        Uri.parse('http://localhost:3000/tournament/$tournamentId/participants'),
      );

      final matchesResponse = await http.get(
        Uri.parse('http://localhost:3000/tournament/$tournamentId/matches'),
      );

      if (participantsResponse.statusCode == 200 && matchesResponse.statusCode == 200) {
        setState(() {
          participants = jsonDecode(participantsResponse.body);
          matches = jsonDecode(matchesResponse.body);
          maxRounds = calculateMaxRounds();
          isLoadingData = false;
        });
      } else {
        print('Failed to fetch tournament data');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch tournament data')),
        );
        setState(() {
          isLoadingData = false;
        });
      }
    } catch (e) {
      print('Error fetching tournament data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tournament data')),
      );
      setState(() {
        isLoadingData = false;
      });
    }
  }

  List<int> calculateMaxRounds() {
    int maxRound = 0;
    for (var match in matches) {
      int round = match['match']['round'];
      if (round > maxRound) {
        maxRound = round;
      }
    }
    return List<int>.generate(maxRound, (index) => index + 1);
  }

  void showMatchDetails(BuildContext context, Map<String, dynamic> match) {
    final player1 = getPlayer(match['player1_id']);
    final player2 = getPlayer(match['player2_id']);
    final winner = getPlayer(match['winner_id']);
    final loser = getPlayer(match['loser_id']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Match Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Player 1: ${player1?['participant']['name'] ?? 'TBD'}'),
              Text('Player 2: ${player2?['participant']['name'] ?? 'TBD'}'),
              if (winner != null)
                Text('Winner: ${winner['participant']['name']}'),
              if (loser != null) Text('Loser: ${loser['participant']['name']}'),
              if (match['scores_csv'] != null && match['scores_csv'] != "")
                Text('Scores: ${match['scores_csv']}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournament Bracket'),
      ),
      body: isLoadingData
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(maxRounds.length, (index) {
                  int currentRound = maxRounds[index];
                  List<dynamic> roundMatches = matches
                      .where((match) => match['match']['round'] == currentRound)
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(roundMatches.length, (matchIndex) {
                      final match = roundMatches[matchIndex]['match'];
                      final player1 = getPlayer(match['player1_id']);
                      final player2 = getPlayer(match['player2_id']);
                      return Container(
                        margin: EdgeInsets.only(
                            right: _matchRightPadding, bottom: _minMargin),
                        child: GestureDetector(
                          onTap: () => showMatchDetails(context, match),
                          child: MatchWidget(
                            match: match,
                            player1: player1,
                            player2: player2,
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
    );
  }

  Map<String, dynamic>? getPlayer(int? playerId) {
    if (playerId == null) return null;
    return participants.firstWhere(
      (p) => p['participant']['id'] == playerId,
      orElse: () => null,
    );
  }
}

class MatchWidget extends StatelessWidget {
  final Map<String, dynamic> match;
  final Map<String, dynamic>? player1;
  final Map<String, dynamic>? player2;

  const MatchWidget({
    Key? key,
    required this.match,
    this.player1,
    this.player2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _matchHeight,
      width: _matchWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Text(
              player1 != null ? player1!['participant']['name'] : 'TBD',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(
            height: 20,
            thickness: 1,
            color: Colors.black,
          ),
          Expanded(
            child: Text(
              player2 != null ? player2!['participant']['name'] : 'TBD',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
