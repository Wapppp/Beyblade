import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageRankingsPage extends StatefulWidget {
  @override
  _ManageRankingsPageState createState() => _ManageRankingsPageState();
}

class _ManageRankingsPageState extends State<ManageRankingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Rankings'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Blader Name',
                prefixIcon: Icon(Icons.search),
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
                  .collection('users')
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
                  return Center(child: Text('No users found.'));
                }

                return DataTable(
                  columns: [
                    DataColumn(label: Text('Blader Name')),
                    DataColumn(label: Text('UserID')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Points')),
                    DataColumn(label: Text('Rank')),
                    DataColumn(label: Text('Won')),
                    DataColumn(label: Text('Lost')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: snapshot.data!.docs.map((user) {
                    var bladerName = user['blader_name'] ?? 'No Name';
                    var userId = user.id;
                    var userEmail = user['email'] ?? 'No Email';
                    var userPoints = user['points'] ?? 0;
                    var userRank = user['rank'] ?? 'No Rank';
                    var userWon = user['won'] ?? 0;
                    var userLost = user['lost'] ?? 0;

                    return DataRow(
                      cells: [
                        DataCell(Text(bladerName)),
                        DataCell(Text(userId)),
                        DataCell(Text(userEmail)),
                        DataCell(Text(userPoints.toString())),
                        DataCell(Text(userRank)),
                        DataCell(Text(userWon.toString())),
                        DataCell(Text(userLost.toString())),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditDialog(context, user, userPoints,
                                  userRank, userWon, userLost);
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot user, int? points,
      String? rank, int? won, int? lost) {
    TextEditingController pointsController =
        TextEditingController(text: points?.toString() ?? '');
    TextEditingController rankController =
        TextEditingController(text: rank ?? '');
    TextEditingController wonController =
        TextEditingController(text: won?.toString() ?? '');
    TextEditingController lostController =
        TextEditingController(text: lost?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Details'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: pointsController,
                  decoration: InputDecoration(labelText: 'Points'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: rankController,
                  decoration: InputDecoration(labelText: 'Rank'),
                ),
                TextField(
                  controller: wonController,
                  decoration: InputDecoration(labelText: 'Won'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: lostController,
                  decoration: InputDecoration(labelText: 'Lost'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                int? updatedPoints = pointsController.text.isNotEmpty
                    ? int.tryParse(pointsController.text)
                    : null;
                String updatedRank = rankController.text;
                int? updatedWon = wonController.text.isNotEmpty
                    ? int.tryParse(wonController.text)
                    : null;
                int? updatedLost = lostController.text.isNotEmpty
                    ? int.tryParse(lostController.text)
                    : null;

                Map<String, dynamic> updateData = {};
                if (updatedPoints != null) {
                  updateData['points'] = updatedPoints;
                }
                if (updatedRank.isNotEmpty) {
                  updateData['rank'] = updatedRank;
                }
                if (updatedWon != null) {
                  updateData['won'] = updatedWon;
                }
                if (updatedLost != null) {
                  updateData['lost'] = updatedLost;
                }

                await _firestore
                    .collection('users')
                    .doc(user.id)
                    .update(updateData);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
