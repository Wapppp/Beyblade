import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateBracketScreen extends StatefulWidget {
  final String tournamentId;

  CreateBracketScreen({required this.tournamentId});

  @override
  _CreateBracketScreenState createState() => _CreateBracketScreenState();
}

class _CreateBracketScreenState extends State<CreateBracketScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  List<String> players = [];
  String selectedFormat = 'Single Elimination';

  Future<void> _createChallongeTournament() async {
    String apiUrl = 'http://localhost:64297/'; // Replace with your server URL

    try {
      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json', // Ensure correct content type
          },
          body: jsonEncode({
            'tournament[name]': 'Flutter Tournament',
            'tournament[url]': 'flutter_tournament',
            'tournament[tournament_type]': selectedFormat.toLowerCase(),
            'tournament[open_signup]': 'true',
            'tournament[description]': 'Flutter tournament description',
            // Add more parameters as needed
          }));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Tournament created: $jsonData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Challonge Tournament created successfully')),
        );
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
