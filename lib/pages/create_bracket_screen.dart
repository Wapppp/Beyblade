import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class CreateBracketScreen extends StatefulWidget {
  final String tournamentId;

  CreateBracketScreen({required this.tournamentId});

  @override
  _CreateBracketScreenState createState() => _CreateBracketScreenState();
}

class _CreateBracketScreenState extends State<CreateBracketScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _playerNameController = TextEditingController();
  List<String> players = [];
  String selectedFormat = 'Single Elimination';

  void _addPlayer() {
    setState(() {
      players.add(_playerNameController.text.trim());
      _playerNameController.clear();
    });
  }

  Future<void> _createBracket() async {
    try {
      List<String> shuffledPlayers = List.from(players)..shuffle(Random());

      Map<String, dynamic> matches = {};
      if (selectedFormat == 'Single Elimination') {
        matches = _createSingleEliminationBracket(shuffledPlayers);
      } else if (selectedFormat == 'Double Elimination') {
        matches = _createDoubleEliminationBracket(shuffledPlayers);
      } else if (selectedFormat == 'Swiss') {
        matches = _createSwissBracket(shuffledPlayers);
      }

      await _firestore
          .collection('tournaments')
          .doc(widget.tournamentId)
          .update({
        'matches': matches,
        'format': selectedFormat,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bracket created successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error creating bracket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating bracket')),
      );
    }
  }

  Map<String, dynamic> _createSingleEliminationBracket(List<String> players) {
    Map<String, dynamic> matches = {};
    int matchNumber = 1;
    for (int i = 0; i < players.length; i += 2) {
      matches['Match $matchNumber'] = {
        'player1': players[i],
        'player2': players.length > i + 1 ? players[i + 1] : 'Bye',
      };
      matchNumber++;
    }
    return matches;
  }

  Map<String, dynamic> _createDoubleEliminationBracket(List<String> players) {
    Map<String, dynamic> matches = {};
    int matchNumber = 1;
    int round = 1;

    // First round
    for (int i = 0; i < players.length; i += 2) {
      matches['Round $round - Match $matchNumber'] = {
        'player1': players[i],
        'player2': players.length > i + 1 ? players[i + 1] : 'Bye',
        'winner': '',
        'loser': ''
      };
      matchNumber++;
    }

    // Simulate progression for winner and loser brackets (simplified version)
    for (int i = 1; i <= players.length; i++) {
      matches['Winners Round ${round + i} - Match $matchNumber'] = {
        'player1': 'Winner of Match ${matchNumber - i * 2 + 1}',
        'player2': 'Winner of Match ${matchNumber - i * 2 + 2}',
        'winner': '',
        'loser': ''
      };
      matchNumber++;

      matches['Losers Round ${round + i} - Match $matchNumber'] = {
        'player1': 'Loser of Match ${matchNumber - i * 2 + 1}',
        'player2': 'Loser of Match ${matchNumber - i * 2 + 2}',
        'winner': '',
        'loser': ''
      };
      matchNumber++;
    }

    return matches;
  }

  Map<String, dynamic> _createSwissBracket(List<String> players) {
    Map<String, dynamic> matches = {};
    int matchNumber = 1;
    int round = 1;
    int rounds = (log(players.length) / log(2)).ceil();

    for (int r = 1; r <= rounds; r++) {
      matches['Round $round'] = [];
      List<String> roundPlayers = List.from(players);

      while (roundPlayers.length > 1) {
        String player1 = roundPlayers.removeLast();
        String player2 = roundPlayers.removeLast();
        matches['Round $round'].add({
          'match': 'Match $matchNumber',
          'player1': player1,
          'player2': player2,
          'winner': '',
        });
        matchNumber++;
      }

      // If odd number of players, one gets a bye
      if (roundPlayers.isNotEmpty) {
        matches['Round $round'].add({
          'match': 'Match $matchNumber',
          'player1': roundPlayers.removeLast(),
          'player2': 'Bye',
          'winner': '',
        });
        matchNumber++;
      }
      round++;
    }

    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Bracket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _playerNameController,
              decoration: InputDecoration(
                labelText: 'Player Name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addPlayer,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            DropdownButton<String>(
              value: selectedFormat,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFormat = newValue!;
                });
              },
              items: <String>[
                'Single Elimination',
                'Double Elimination',
                'Swiss'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(players[index]),
                  );
                },
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: _createBracket,
                child: Text('Create Bracket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
