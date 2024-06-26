import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl package for DateFormat

class NewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
        backgroundColor: Colors.grey[900],
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
        stream: FirebaseFirestore.instance.collection('news').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No news available',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var newsItem = snapshot.data!.docs[index];
              Map<String, dynamic>? data =
                  newsItem.data() as Map<String, dynamic>?;

              DateTime? date =
                  data != null ? (data['date'] as Timestamp).toDate() : null;

              return InkWell(
                onTap: () {
                  _showNewsDetails(context, data);
                },
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.fromLTRB(
                      10, 10, 10, 20), // Added bottom margin
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (data != null && data.containsKey('image'))
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(data['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      data.containsKey('title')
                                          ? data['title']
                                          : 'Title not available',
                                      style: TextStyle(
                                        fontSize: 24, // Larger font size
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (data != null && data.containsKey('description'))
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            data['description'] ??
                                '', // Handle potential null value
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      if (date != null) // Display publication date if available
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Published on: ${DateFormat('MMMM dd, yyyy').format(date)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showNewsDetails(BuildContext context, Map<String, dynamic>? data) {
    if (data == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: data.containsKey('title')
            ? Center(
                child: Text(
                  data['title'],
                  style: TextStyle(
                    fontSize: 24, // Larger font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data.containsKey('image'))
                Image.network(
                  data['image'] ?? '', // Handle potential null value
                  fit: BoxFit.cover,
                  height: 200, // Adjust the height as needed
                ),
              if (data.containsKey('description')) SizedBox(height: 8),
              Text(
                data['description'] ?? '', // Handle potential null value
                style: TextStyle(fontSize: 16),
              ),
              if (data
                  .containsKey('date')) // Display publication date if available
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Published on: ${DateFormat('MMMM dd, yyyy').format(data['date'].toDate())}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
