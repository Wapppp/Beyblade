import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tournament_details_page.dart'; // Import TournamentDetailsPage and TournamentEvent from correct file

enum TournamentStatus {
  Upcoming,
  Ongoing,
  Started,
  Ended,
}

class TournamentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournaments'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .orderBy('date')
            .limit(20) // Limiting to 20 tournaments
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No tournaments available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[200], // White text color
                ),
              ),
            );
          }

          final now = DateTime.now();
          final tournaments = snapshot.data!.docs.map((doc) {
            Timestamp dateTimestamp = doc['date'];
            return TournamentEvent(
              id: doc.id,
              name: doc['name'],
              date: dateTimestamp,
              location: doc['location'],
              description: doc['description'],
            );
          }).toList();

          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
<<<<<<< HEAD
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  elevation: 4,
                  color: Colors.grey[850], // Dark grey card background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    title: Text(
                      tournament.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text color
=======
              final status = _getTournamentStatus(tournament.date, now);

              return ListTile(
                title: Text(tournament.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatTimestamp(tournament.date)),
                    _buildStatusWidget(status),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TournamentDetailsPage(
                        tournament: tournament,
>>>>>>> 7adfd8d59a2b476e59ceca7caba4d2eb7b2c62a2
                      ),
                    ),
                    subtitle: Text(
                      _formatTimestamp(tournament.date),
                      style: TextStyle(
                        color: Colors.white70, // White70 text color
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TournamentDetailsPage(
                            tournament: tournament, // Pass tournament object
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    // Customize formatting as needed (e.g., 'yyyy-MM-dd HH:mm')
  }

  Widget _buildStatusWidget(TournamentStatus status) {
    String statusText = '';
    Color statusColor = Colors.grey;

    switch (status) {
      case TournamentStatus.Upcoming:
        statusText = 'Upcoming';
        statusColor = Colors.blue;
        break;
      case TournamentStatus.Ongoing:
        statusText = 'Ongoing';
        statusColor = Colors.green;
        break;
      case TournamentStatus.Started:
        statusText = 'Started';
        statusColor = Colors.orange;
        break;
      case TournamentStatus.Ended:
        statusText = 'Ended';
        statusColor = Colors.red;
        break;
    }

    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TournamentStatus _getTournamentStatus(
      Timestamp tournamentDate, DateTime now) {
    DateTime dateTime = tournamentDate.toDate();

    if (now.isBefore(dateTime)) {
      // Tournament date is in the future
      final difference = dateTime.difference(now);
      if (difference.inDays > 0) {
        return TournamentStatus.Upcoming;
      } else {
        return TournamentStatus.Started;
      }
    } else if (now.isAfter(dateTime)) {
      // Tournament date is in the past
      return TournamentStatus.Ended;
    } else {
      // Tournament is happening now
      return TournamentStatus.Ongoing;
    }
  }
}
