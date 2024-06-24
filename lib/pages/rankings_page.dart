import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<Map<String, dynamic>> players = [];

  @override
  void initState() {
    super.initState();
    _fetchTopPlayers();
  }

  Future<void> _fetchTopPlayers() async {
    try {
      final QuerySnapshot playerStatsSnapshot = await _firestore
          .collection('playerstats')
          .orderBy('total_wins', descending: true)
          .limit(100)
          .get();

      setState(() {
        players = playerStatsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching top players: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top 100 Players'),
      ),
      body: players.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                var player = players[index];
                return _buildPlayerCard(index + 1, player);
              },
            ),
    );
  }

  Widget _buildPlayerCard(int rank, Map<String, dynamic> player) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$rank. ${player['blader_name']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'MMR: ${_calculateMMR(player['total_wins'], player['total_losses'], player['total_points'])}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'As of: ${_formatDate(player['last_updated'])}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Icon(Icons.star, color: Colors.amber),
          ],
        ),
      ),
    );
  }

  int _calculateMMR(int totalWins, int totalLosses, int totalPoints) {
    // Your MMR calculation logic here
    // Example: This is a simple example, adjust based on your specific formula
    return totalWins * 3 + totalLosses * 1 + totalPoints * 2;
  }

  String _formatDate(Timestamp timestamp) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    return '${date.day}/${date.month}/${date.year}';
  }
}
