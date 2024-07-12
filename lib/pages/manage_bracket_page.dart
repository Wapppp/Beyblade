import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageBracketPage extends StatefulWidget {
  final String tournamentId;
  final String serverUrl =
      'http://localhost:3000'; // Replace with your server URL

  ManageBracketPage({required this.tournamentId});

  @override
  _ManageBracketPageState createState() => _ManageBracketPageState();
}

class _ManageBracketPageState extends State<ManageBracketPage> {
  Map<String, dynamic>? tournamentData;

  @override
  void initState() {
    super.initState();
    _fetchTournamentDetails();
  }

  Future<void> _fetchTournamentDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.serverUrl}/tournament/${widget.tournamentId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          tournamentData = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch tournament details: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch tournament details')),
        );
      }
    } catch (e) {
      print('Error fetching tournament details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tournament details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bracket for ${widget.tournamentId}'),
      ),
      body: tournamentData == null
          ? Center(child: CircularProgressIndicator())
          : _buildTournamentDetails(),
    );
  }

  Widget _buildTournamentDetails() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        ListTile(
          title: Text('Tournament Name:'),
          subtitle: Text(tournamentData!['name'] ?? 'N/A'),
        ),
        ListTile(
          title: Text('Description:'),
          subtitle: Text(tournamentData!['description'] ?? 'N/A'),
        ),
        ListTile(
          title: Text('Tournament Type:'),
          subtitle: Text(tournamentData!['tournament_type'] ?? 'N/A'),
        ),
        // Add more details as needed
      ],
    );
  }
}
