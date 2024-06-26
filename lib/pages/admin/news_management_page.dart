import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_news_page.dart'; // Import AddNewsPage

class NewsManagementPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage News'),
        // Customize app bar as needed
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                _addNews(context); // Navigate to AddNewsPage
              },
              child: Text('Add News'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('news').snapshots(),
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
                    itemBuilder: (context, index) {
                      var newsItem = snapshot.data!.docs[index];
                      return Card(
                        color: Colors.grey[850],
                        child: ListTile(
                          title: Text(
                            newsItem['title'],
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            newsItem['description'],
                            style: TextStyle(color: Colors.grey),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteNews(newsItem.id);
                            },
                          ),
                          onTap: () {
                            _editNews(context, newsItem);
                          },
                        ),
                      );
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

  void _addNews(BuildContext context) {
    // Navigate to add news page or dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNewsPage()),
    );
  }

  void _editNews(BuildContext context, DocumentSnapshot newsItem) {
    // Navigate to edit news page or dialog
    // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => EditNewsPage(newsItem: newsItem)));
    // Ensure to create EditNewsPage for editing news functionality
  }

  void _deleteNews(String newsId) {
    _firestore.collection('news').doc(newsId).delete().then((_) {
      print('News item deleted successfully');
    }).catchError((error) {
      print('Error deleting news item: $error');
      // Handle error
    });
  }
}
