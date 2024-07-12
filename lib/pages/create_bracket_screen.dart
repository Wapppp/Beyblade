import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateBracketScreen extends StatefulWidget {
  final String tournamentId;

  CreateBracketScreen({required this.tournamentId});

  @override
  _CreateBracketScreenState createState() => _CreateBracketScreenState();
}

class _CreateBracketScreenState extends State<CreateBracketScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  List<String> players = [];
  String selectedFormat = 'single elimination';
  final String apiKey =
      'aVlprOzueD1KvIkm7dRnuhxGaPFoeu8xRGIvPyPa'; // Replace with your Challonge API Key

  Future<void> _createChallongeTournament() async {
    String apiUrl =
        'http://localhost:3000/create-tournament'; // Proxy server URL

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tournament': {
            'name': 'Flutter Tournament',
            'url':
                'flutter_tournament_${DateTime.now().millisecondsSinceEpoch}',
            'tournament_type': selectedFormat,
            'open_signup': true,
            'description': 'Flutter tournament description',
          }
        }),
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Tournament created: $jsonData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Challonge Tournament created successfully')),
        );

        int tournamentId = jsonData['tournament']['id'];
        await _addPlayersToTournament(tournamentId);

        // Save tournament details to Firestore
        await _saveTournamentToFirestore(jsonData['tournament']);

        // Fetch tournament details from server based on challongeId
        await _fetchTournamentDetails(jsonData['tournament']['id']);
      } else {
        print('Failed to create tournament: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create Challonge Tournament')),
        );
      }
    } catch (e) {
      print('Error creating tournament: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating Challonge Tournament')),
      );
    }
  }

  Future<void> _fetchTournamentDetails(int challongeId) async {
    String apiUrl =
        'http://localhost:3000/tournament/$challongeId'; // Endpoint to fetch tournament details

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Tournament details fetched: $jsonData');

        // Display fetched tournament details as needed
        // Example: update UI with tournament details
      } else {
        print('Failed to fetch tournament details: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch Tournament details')),
        );
      }
    } catch (e) {
      print('Error fetching tournament details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching Tournament details')),
      );
    }
  }

  Future<void> _saveTournamentToFirestore(
      Map<String, dynamic> tournamentData) async {
    try {
      await FirebaseFirestore.instance.collection('tournaments').add({
        'name': tournamentData['name'],
        'challongeId': tournamentData['id'],
        'url': tournamentData['url'],
        'type': tournamentData['tournament_type'],
        'description': tournamentData['description'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Tournament saved to Firestore');
    } catch (error) {
      print('Error saving tournament to Firestore: $error');
    }
  }

  Future<void> _addPlayersToTournament(int tournamentId) async {
    for (String player in players) {
      String apiUrl =
          'http://localhost:3000/add-player'; // Proxy server URL for adding players

      try {
        final response = await http.post(Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'tournament_id': tournamentId,
              'participant': {
                'name': player,
              }
            }));

        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          print('Player added: $jsonData');
        } else {
          print('Failed to add player: ${response.statusCode}');
        }
      } catch (e) {
        print('Error adding player: $e');
      }
    }
  }

  void _addPlayer() {
    setState(() {
      players.add(_playerNameController.text.trim());
      _playerNameController.clear();
    });
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
                'single elimination',
                'double elimination',
                'round robin',
                'swiss'
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
                onPressed: _createChallongeTournament,
                child: Text('Create Challonge Tournament'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }
}
