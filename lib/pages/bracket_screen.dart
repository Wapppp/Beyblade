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
  bool isTournamentStarted = false;
  bool isTournamentFinalized = false;

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
        Uri.parse(
            'http://localhost:3000/tournament/$tournamentId/participants'),
      );

      final matchesResponse = await http.get(
        Uri.parse('http://localhost:3000/tournament/$tournamentId/matches'),
      );

      if (participantsResponse.statusCode == 200 &&
          matchesResponse.statusCode == 200) {
        setState(() {
          participants = jsonDecode(participantsResponse.body);
          matches = jsonDecode(matchesResponse.body);
          maxRounds = calculateMaxRounds();
          isLoadingData = false;
        });
        checkTournamentState();
      } else {
        throw Exception('Failed to fetch tournament data');
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

  void checkTournamentState() {
    for (var match in matches) {
      if (match['match']['state'] == 'open' ||
          match['match']['state'] == 'complete') {
        setState(() {
          isTournamentStarted = true;
        });
        return;
      }
    }
    setState(() {
      isTournamentStarted = false;
    });
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
    String player1Score = '';
    String player2Score = '';
    int? winnerId = match['winner_id'];
    String matchScore =
        match['scores_csv'] ?? 'Not reported'; // Access scores_csv directly

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Match Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Player 1: ${player1?['participant']['name'] ?? 'TBD'}'),
                  Text('Player 2: ${player2?['participant']['name'] ?? 'TBD'}'),

                  // Display match score
                  Text('Score: $matchScore'),

                  // Show winner if available
                  if (winnerId != null)
                    Text(
                        'Winner: ${getPlayer(winnerId)?['participant']['name'] ?? 'TBD'}'),

                  // Input fields for reporting scores if winner is not yet determined
                  if (winnerId == null) ...[
                    TextField(
                      decoration: InputDecoration(labelText: 'Player 1 Score'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        player1Score = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Player 2 Score'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        player2Score = value;
                      },
                    ),
                    ListTile(
                      title: Text('Player 1 wins'),
                      leading: Radio<int>(
                        value: match['player1_id'],
                        groupValue: winnerId,
                        onChanged: (int? value) {
                          setDialogState(() {
                            winnerId = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Player 2 wins'),
                      leading: Radio<int>(
                        value: match['player2_id'],
                        groupValue: winnerId,
                        onChanged: (int? value) {
                          setDialogState(() {
                            winnerId = value;
                          });
                        },
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
                if (winnerId == null)
                  TextButton(
                    onPressed: () {
                      final loserId = (winnerId == match['player1_id'])
                          ? match['player2_id']
                          : match['player1_id'];
                      reportScore(match['id'], player1Score, player2Score,
                          winnerId, loserId);
                      Navigator.of(context).pop();
                    },
                    child: Text('Report Score'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> reportScore(int matchId, String player1Score,
      String player2Score, int? winnerId, int? loserId) async {
    final url =
        'http://localhost:3000/tournaments/${widget.tournamentId}/matches/$matchId';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'match': {
          'scores_csv': '$player1Score-$player2Score',
          'winner_id': winnerId,
          'loser_id': loserId,
        },
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Score reported successfully')),
      );
      fetchTournamentData(widget.tournamentId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to report score')),
      );
    }
  }

  Future<void> startTournament() async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:3000/tournaments/${widget.tournamentId}/start'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tournament started successfully')),
      );
      setState(() {
        isTournamentStarted = true;
      });
      fetchTournamentData(widget.tournamentId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start tournament')),
      );
    }
  }

  Future<void> finalizeTournament() async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:3000/tournaments/${widget.tournamentId}/finalize'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tournament finalized successfully')),
      );
      setState(() {
        isTournamentFinalized = true;
      });
      fetchTournamentData(widget.tournamentId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to finalize tournament')),
      );
    }
  }

  Map<String, dynamic>? getPlayer(int? playerId) {
    return participants.firstWhere(
      (participant) => participant['participant']['id'] == playerId,
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournament Bracket'),
        actions: [
          if (!isTournamentStarted)
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: startTournament,
            ),
          if (isTournamentStarted && !isTournamentFinalized)
            IconButton(
              icon: Icon(Icons.flag),
              onPressed: finalizeTournament,
            ),
        ],
      ),
      body: isLoadingData
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: maxRounds.length,
              itemBuilder: (context, roundIndex) {
                int currentRound = maxRounds[roundIndex];
                List<dynamic> roundMatches = matches
                    .where((match) => match['match']['round'] == currentRound)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: roundMatches.map((matchData) {
                    final match = matchData['match'];
                    final player1 = getPlayer(match['player1_id']);
                    final player2 = getPlayer(match['player2_id']);

                    return Container(
                      margin: EdgeInsets.only(
                          right: _matchRightPadding, bottom: _minMargin),
                      child: GestureDetector(
                        onTap: () => showMatchDetails(context, match),
                        child: matchBox(player1, player2),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }

  Widget matchBox(
      Map<String, dynamic>? player1, Map<String, dynamic>? player2) {
    return Container(
      height: _matchHeight,
      width: _matchWidth,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              player1 != null ? player1['participant']['name'] : 'TBD',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(color: Colors.black),
          Expanded(
            child: Text(
              player2 != null ? player2['participant']['name'] : 'TBD',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
