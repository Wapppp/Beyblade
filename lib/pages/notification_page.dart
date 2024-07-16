import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Stream<QuerySnapshot> _notificationsStream;

  @override
  void initState() {
    super.initState();
    // Initialize stream to fetch notifications
    _notificationsStream = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notifications'));
          }

          // Display notifications
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              Timestamp createdAt = data['createdAt'] as Timestamp;
              String message = data['message'] as String;
              String userId = data['userId'] ?? ''; // Handle if userId is null
              String agencyId = data['agencyId'] ?? ''; // Handle if agencyId is null

              return Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    message,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Received: ${createdAt.toDate().toString()}',
                        style: TextStyle(fontSize: 12.0),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Sent by: $userId', // Display userId who sent the invitation
                        style: TextStyle(fontSize: 12.0),
                      ),
                      Text(
                        'Agency ID: $agencyId', // Display agencyId related to the invitation
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}