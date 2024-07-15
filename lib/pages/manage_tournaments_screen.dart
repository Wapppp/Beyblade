import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tournament_detail_screen.dart';

class ManageTournamentsScreen extends StatefulWidget {
  @override
  _ManageTournamentsScreenState createState() =>
      _ManageTournamentsScreenState();
}

class _ManageTournamentsScreenState extends State<ManageTournamentsScreen> {
  List<dynamic> tournaments = [];
  final String apiUrl =
      'http://localhost:3000/tournaments'; // Replace with your API URL

  Future<void> fetchTournaments() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          tournaments = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch tournaments: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch tournaments')),
        );
      }
    } catch (e) {
      print('Error fetching tournaments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tournaments')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tournaments'),
      ),
      body: ListView.builder(
        itemCount: tournaments.length,
        itemBuilder: (context, index) {
          final tournament = tournaments[index]['tournament'];
          return ListTile(
            title: Text(tournament['name'] ?? 'No name'),
            subtitle: Text(tournament['description'] ?? 'No description'),
            trailing: Icon(Icons.info),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TournamentDetailScreen(tournament: tournament),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create tournament screen
          Navigator.pushNamed(context, '/create-tournament');
        },
        child: Icon(Icons.add),
        tooltip: 'Create Tournament',
      ),
    );
  }
}
