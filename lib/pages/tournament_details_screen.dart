import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'manage_participants_page.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TournamentDetailsScreen extends StatelessWidget {
  final DocumentSnapshot tournamentDoc;

  const TournamentDetailsScreen({Key? key, required this.tournamentDoc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournament Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('organizers')
            .doc(tournamentDoc['organizerId'])
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Organizer not found'));
          }

          final organizerName = snapshot.data!['organizer_name'];

          // Convert Firestore Timestamp to DateTime
          Timestamp timestamp = tournamentDoc['date'];
          DateTime date = timestamp.toDate();

          // Format the DateTime using DateFormat
          String formattedDate = DateFormat.yMMMMd().add_jm().format(date);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tournamentDoc['name'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Organizer: $organizerName',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Date: $formattedDate',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Location: ${tournamentDoc['location']}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Description: ${tournamentDoc['description']}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Participants:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
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

                      final participants = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          var participantData = participants[index].data()
                              as Map<String, dynamic>;
                          return ListTile(
                            title: Text(
                                participantData['blader_name'] ?? 'Unknown'),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _navigateToManageParticipants(context);
                  },
                  child: Text('Manage Participants'),
                ),
                SizedBox(height: 20),
                _buildQrCodeContainer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrCodeContainer() {
    return FutureBuilder<String>(
      future: _getQrCodeUrl(tournamentDoc.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 200,
            height: 200,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Container(
            width: 200,
            height: 200,
            color: Colors.grey[300],
            child: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }
        final qrCodeUrl = snapshot.data!;
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(qrCodeUrl),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Future<String> _getQrCodeUrl(String eventId) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('qr_codes/$eventId.png');
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }

  void _navigateToManageParticipants(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ManageParticipantsPage(tournamentDoc: tournamentDoc),
      ),
    );
  }
}
