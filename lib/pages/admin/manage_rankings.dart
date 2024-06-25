import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageRankingsPage extends StatefulWidget {
  @override
  _ManageRankingsPageState createState() => _ManageRankingsPageState();
}

class _ManageRankingsPageState extends State<ManageRankingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _searchController;
  late ScrollController
      _scrollController; // ScrollController for the SingleChildScrollView

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController(); // Initialize the ScrollController
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Rankings'),
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
        color: Colors.grey[900],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Blader Name',
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild on text change
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('playerstats')
                    .where('blader_name',
                        isGreaterThanOrEqualTo: _searchController.text.trim())
                    .where('blader_name',
                        isLessThanOrEqualTo:
                            _searchController.text.trim() + '\uf8ff')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No players found.'));
                  }

                  return Scrollbar(
                    thumbVisibility: true, // Ensure scrollbar is always visible
                    controller:
                        _scrollController, // Assign ScrollController to Scrollbar
                    child: SingleChildScrollView(
                      controller:
                          _scrollController, // Assign ScrollController to SingleChildScrollView
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width),
                        child: DataTable(
                          columns: [
                            DataColumn(
                                label: Text('Blader Name',
                                    style: TextStyle(color: Colors.white))),
                            DataColumn(
                                label: Text('Last Updated',
                                    style: TextStyle(color: Colors.white))),
                            DataColumn(
                                label: Text('Total Points',
                                    style: TextStyle(color: Colors.white))),
                            DataColumn(
                                label: Text('Total Wins',
                                    style: TextStyle(color: Colors.white))),
                            DataColumn(
                                label: Text('Total Losses',
                                    style: TextStyle(color: Colors.white))),
                            DataColumn(
                                label: Text('MMR',
                                    style: TextStyle(color: Colors.white))),
                            DataColumn(
                                label: Text('Actions',
                                    style: TextStyle(color: Colors.white))),
                          ],
                          rows: snapshot.data!.docs.map((player) {
                            var bladerName = player['blader_name'] ?? 'No Name';
                            var lastUpdated = player['last_updated'] != null
                                ? (player['last_updated'] as Timestamp)
                                    .toDate()
                                    .toString()
                                : 'Unknown';
                            var totalPoints = player['total_points'] ?? 0;
                            var totalWins = player['total_wins'] ?? 0;
                            var totalLosses = player['total_losses'] ?? 0;
                            var mmr = _calculateMMR(
                                totalWins, totalLosses, totalPoints);

                            return DataRow(
                              cells: [
                                DataCell(Text(bladerName,
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(lastUpdated,
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(totalPoints.toString(),
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(totalWins.toString(),
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(totalLosses.toString(),
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(mmr.toString(),
                                    style: TextStyle(color: Colors.white))),
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.white),
                                    onPressed: () {
                                      _showEditDialog(context, player,
                                          totalPoints, totalWins, totalLosses);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    DocumentSnapshot player,
    int points,
    int wins,
    int losses,
  ) {
    TextEditingController pointsController =
        TextEditingController(text: points.toString());
    TextEditingController winsController =
        TextEditingController(text: wins.toString());
    TextEditingController lossesController =
        TextEditingController(text: losses.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text('Edit Player Stats', style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: pointsController,
                  decoration: InputDecoration(
                      labelText: 'Total Points',
                      labelStyle: TextStyle(color: Colors.black)),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: winsController,
                  decoration: InputDecoration(
                      labelText: 'Total Wins',
                      labelStyle: TextStyle(color: Colors.black)),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: lossesController,
                  decoration: InputDecoration(
                      labelText: 'Total Losses',
                      labelStyle: TextStyle(color: Colors.black)),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          backgroundColor: Colors.grey[200],
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: Colors.black)),
              onPressed: () async {
                int updatedPoints =
                    int.tryParse(pointsController.text) ?? points;
                int updatedWins = int.tryParse(winsController.text) ?? wins;
                int updatedLosses =
                    int.tryParse(lossesController.text) ?? losses;

                Map<String, dynamic> updateData = {
                  'total_points': updatedPoints,
                  'total_wins': updatedWins,
                  'total_losses': updatedLosses,
                };

                await _firestore
                    .collection('playerstats')
                    .doc(player.id)
                    .update(updateData);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  int _calculateMMR(int totalWins, int totalLosses, int totalPoints) {
    // Simple example of MMR calculation
    return totalWins * 3 + totalLosses * 1 + totalPoints * 2;
  }
}
