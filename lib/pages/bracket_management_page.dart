import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_bracket_screen.dart'; // Import the CreateBracketScreen

import 'dart:math';

class BracketManagementPage extends StatefulWidget {
  final String tournamentId;

  BracketManagementPage({required this.tournamentId});

  @override
  _BracketManagementPageState createState() => _BracketManagementPageState();
}

class _BracketManagementPageState extends State<BracketManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _bracket; // Changed to nullable

  @override
  void initState() {
    super.initState();
    _loadBracket();
  }

  void _loadBracket() async {
    try {
      DocumentSnapshot tournamentSnapshot = await _firestore
          .collection('tournaments')
          .doc(widget.tournamentId)
          .get();

      setState(() {
        _bracket = tournamentSnapshot['bracket'];
      });
    } catch (error) {
      print('Error loading bracket: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bracket for ${widget.tournamentId}'),
      ),
      body: _bracket == null
          ? Center(child: CircularProgressIndicator())
          : _buildBracketList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToCreateBracketScreen();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBracketList() {
    if (_bracket == null || _bracket!.isEmpty) {
      return Center(
        child: Text('No matches available'),
      );
    }

    return ListView.builder(
      itemCount: _bracket!.length,
      itemBuilder: (context, index) {
        String matchKey = _bracket!.keys.elementAt(index);
        Map<String, dynamic> match = _bracket![matchKey];

        if (match == null) {
          return SizedBox.shrink(); // or any placeholder widget for null match
        }

        // Determine the bracket type
        String bracketType = match['type'] ?? ''; // Ensure 'type' is not null

        // Define UI based on bracket type
        Widget bracketTile;
        if (bracketType == 'Single Elimination') {
          bracketTile = _buildSingleEliminationTile(match);
        } else if (bracketType == 'Double Elimination') {
          bracketTile = _buildDoubleEliminationTile(match);
        } else if (bracketType == 'Swiss') {
          bracketTile = _buildSwissTile(match);
        } else {
          bracketTile = _buildDefaultTile(match); // Default case
        }

        return bracketTile;
      },
    );
  }

  Widget _buildSingleEliminationTile(Map<String, dynamic> match) {
    return ListTile(
      title:
          Text(match['title']), // Replace with appropriate title from your data
      subtitle: Text(
        '${match['player1']} vs ${match['player2']} - Winner: ${match['winner']}',
      ),
      // Add other UI elements specific to single elimination if needed
    );
  }

  Widget _buildDoubleEliminationTile(Map<String, dynamic> match) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Double Elimination Match'),
            SizedBox(height: 8),
            Text('${match['player1']} vs ${match['player2']}'),
            SizedBox(height: 8),
            Text('Winner: ${match['winner']}'),
            Text('Loser: ${match['loser']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSwissTile(Map<String, dynamic> match) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Swiss Round'),
          SizedBox(height: 8),
          Text('Match: ${match['match']}'),
          Text('Player 1: ${match['player1']}'),
          Text('Player 2: ${match['player2']}'),
          Text('Winner: ${match['winner']}'),
        ],
      ),
    );
  }

  Widget _buildDefaultTile(Map<String, dynamic> match) {
    return ListTile(
      title: Text(match['title'] ?? 'Match'),
      subtitle: Text(
        '${match['player1']} vs ${match['player2']} - Winner: ${match['winner']}',
      ),
    );
  }

  void _navigateToCreateBracketScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateBracketScreen(tournamentId: widget.tournamentId),
      ),
    );
  }
}
