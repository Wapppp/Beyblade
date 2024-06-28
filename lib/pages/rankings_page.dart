import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_profile.dart';

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> players = [];

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

      List<Map<String, dynamic>> fetchedPlayers = [];

      for (var doc in playerStatsSnapshot.docs) {
        String bladerName = doc['blader_name'];
        String profilePicture = await _fetchProfilePicture(bladerName);

        fetchedPlayers.add({
          'blader_name': bladerName,
          'total_wins': doc['total_wins'],
          'total_losses': doc['total_losses'],
          'profile_picture': profilePicture,
        });
      }

      setState(() {
        players = fetchedPlayers;
      });
    } catch (e) {
      print('Error fetching top players: $e');
    }
  }

  Future<String> _fetchProfilePicture(String bladerName) async {
  try {
    final DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(bladerName).get();

    if (userSnapshot.exists) {
      return userSnapshot['profile_picture'] ?? '';
    } else {
      return ''; // Handle case where user document does not exist
    }
  } catch (e) {
    print('Error fetching profile picture for $bladerName: $e');
    return ''; // Handle error gracefully
  }
}

  void _handleVisit(Map<String, dynamic> player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(
          userProfile: UserProfile(
            bladerName: player['blader_name'],
            won: player['total_wins'] ?? 0,
            lost: player['total_losses'] ?? 0,
            profilePicture: player['profile_picture'] ?? '',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Top 100 Bladers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[900], // Dark background color
        child: players.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 43, 43, 43),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 32,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'BBC Rankings',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        var player = players[index];
                        return _buildPlayerCard(index + 1, player);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPlayerCard(int rank, Map<String, dynamic> player) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[850], // Dark grey card background color
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'MMR: ${_calculateMMR(player['total_wins'], player['total_losses'])}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'As of: ${_formatDate(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            // Visit button
            TextButton(
              onPressed: () {
                _handleVisit(player); // Pass player data to track visit
              },
              child: Text(
                'Visit',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateMMR(int? totalWins, int? totalLosses) {
    // Your MMR calculation logic here
    int wins = totalWins ?? 0;
    int losses = totalLosses ?? 0;
    return wins * 3 + losses * 1; // Adjust this based on your actual MMR formula
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}