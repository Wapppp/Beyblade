import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BracketManagementPage extends StatefulWidget {
  final String tournamentId;

  BracketManagementPage({required this.tournamentId});

  @override
  _BracketManagementPageState createState() => _BracketManagementPageState();
}

class _BracketManagementPageState extends State<BracketManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Map<String, dynamic> _bracket;

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
        title: Text('Manage Bracket'),
      ),
      body: _bracket == null
          ? Center(child: CircularProgressIndicator())
          : _buildBracketList(),
    );
  }

  Widget _buildBracketList() {
    return ListView.builder(
      itemCount: _bracket.length,
      itemBuilder: (context, index) {
        String matchKey = _bracket.keys.elementAt(index);
        Map<String, dynamic> match = _bracket[matchKey];
        return ListTile(
          title: Text(matchKey),
          subtitle: Text(
            '${match['player1']} vs ${match['player2']} - Winner: ${match['winner']}',
          ),
        );
      },
    );
  }
}
