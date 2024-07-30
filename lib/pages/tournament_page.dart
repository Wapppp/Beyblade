import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tournament_details_page.dart'; // Import your details page

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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .orderBy('event_date_time')
            .limit(20)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No tournaments available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final now = DateTime.now();
          final tournaments = snapshot.data!.docs.map((doc) {
            Timestamp dateTimestamp = doc['event_date_time'];
            return TournamentEvent(
              id: doc.id,
              name: doc['name'],
              event_date_time: dateTimestamp,
              location: doc['location'],
              description: doc['description'],
            );
          }).toList();

          // Log the number of tournaments fetched
          print('Fetched tournaments: ${tournaments.length}');

          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              final status =
                  _getTournamentStatus(tournament.event_date_time, now);

              return ListTile(
                title: Text(tournament.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatTimestamp(tournament.event_date_time)),
                    _buildStatusWidget(status),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TournamentDetailsPage(
                        tournament: tournament,
                      ),
                    ),
                  );
                },
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

    // Check if the date is the same day as today
    bool isSameDay = now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;

    if (now.isBefore(dateTime)) {
      return TournamentStatus.Upcoming;
    } else if (now.isAfter(dateTime) || isSameDay) {
      return TournamentStatus.Ongoing;
    } else {
      return TournamentStatus.Ended;
    }
  }
}
