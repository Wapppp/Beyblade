import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageParticipantsPage extends StatefulWidget {
  final DocumentSnapshot tournamentDoc;

  ManageParticipantsPage({Key? key, required this.tournamentDoc})
      : super(key: key);

  @override
  _ManageParticipantsPageState createState() =>
      _ManageParticipantsPageState(tournamentDoc);
}

class _ManageParticipantsPageState extends State<ManageParticipantsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DocumentSnapshot tournamentDoc;
  late List<DocumentSnapshot> participants;

  _ManageParticipantsPageState(this.tournamentDoc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Participants'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tournament: ${tournamentDoc['name']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('participants')
                    .where('tournament_id', isEqualTo: tournamentDoc.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No participants yet.'));
                  }

                  participants = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      var participantDoc = participants[index];
                      var participantData =
                          participantDoc.data() as Map<String, dynamic>;
                      return _buildParticipantTile(
                          participantDoc, participantData);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantTile(
      DocumentSnapshot participantDoc, Map<String, dynamic> participantData) {
    TextEditingController winsController = TextEditingController();
    TextEditingController lossesController = TextEditingController();
    TextEditingController pointsController = TextEditingController();

    winsController.text = participantData.containsKey('wins')
        ? participantData['wins'].toString()
        : '';
    lossesController.text = participantData.containsKey('losses')
        ? participantData['losses'].toString()
        : '';
    pointsController.text = participantData.containsKey('points')
        ? participantData['points'].toString()
        : '';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(participantData['blader_name'] ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: winsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Wins'),
            ),
            TextField(
              controller: lossesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Losses'),
            ),
            TextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Points'),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            _updateParticipantDetails(
              participantDoc.id,
              winsController.text.isNotEmpty
                  ? int.tryParse(winsController.text) ?? 0
                  : participantData.containsKey('wins')
                      ? participantData['wins']
                      : 0,
              lossesController.text.isNotEmpty
                  ? int.tryParse(lossesController.text) ?? 0
                  : participantData.containsKey('losses')
                      ? participantData['losses']
                      : 0,
              pointsController.text.isNotEmpty
                  ? int.tryParse(pointsController.text) ?? 0
                  : participantData.containsKey('points')
                      ? participantData['points']
                      : 0,
              participantData['blader_name'], // Pass blader_name for linking
            );
          },
          child: Text('Update'),
        ),
      ),
    );
  }

  Future<void> _updateParticipantDetails(
    String participantId,
    int wins,
    int losses,
    int points,
    String bladerName,
  ) async {
    try {
      // Update participant details in 'participants' collection
      await _firestore.collection('participants').doc(participantId).update({
        'wins': wins,
        'losses': losses,
        'points': points,
      });

      // Update player stats in 'playerstats' collection using blader_name
      await _firestore.collection('playerstats').doc(bladerName).set({
        'blader_name': bladerName,
        'total_wins': wins,
        'total_losses': losses,
        'total_points': points,
        'last_updated': Timestamp.now(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Participant details updated')),
      );
    } catch (e) {
      print('Error updating participant details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update participant details')),
      );
    }
  }

  Future<void> _storePlayerStats(String userId) async {
    try {
      final QuerySnapshot userParticipants = await _firestore
          .collection('participants')
          .where('user_id', isEqualTo: userId)
          .get();

      int totalWins = 0;
      int totalLosses = 0;
      int totalPoints = 0;

      for (var participant in userParticipants.docs) {
        var participantData = participant.data() as Map<String, dynamic>;
        totalWins +=
            int.tryParse(participantData['wins']?.toString() ?? '0') ?? 0;
        totalLosses +=
            int.tryParse(participantData['losses']?.toString() ?? '0') ?? 0;
        totalPoints +=
            int.tryParse(participantData['points']?.toString() ?? '0') ?? 0;
      }

      await _firestore.collection('playerstats').doc(userId).set({
        'user_id': userId,
        'total_wins': totalWins,
        'total_losses': totalLosses,
        'total_points': totalPoints,
      });
    } catch (e) {
      print('Error storing player stats: $e');
      throw e; // Optional: Throw error for further handling
    }
  }
}
