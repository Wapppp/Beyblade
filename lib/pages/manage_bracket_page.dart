import 'package:flutter/material.dart';

class ManageBracketPage extends StatelessWidget {
  final String tournamentId;

  ManageBracketPage({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bracket for $tournamentId'),
      ),
      body: Center(
        child: Text('Manage Bracket for $tournamentId'),
      ),
    );
  }
}
