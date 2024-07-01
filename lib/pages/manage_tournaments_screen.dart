import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class ManageTournamentsScreen extends StatefulWidget {
  @override
  _ManageTournamentsScreenState createState() =>
      _ManageTournamentsScreenState();
}

class _ManageTournamentsScreenState extends State<ManageTournamentsScreen> {
  List<dynamic> tournaments = [];
  final String apiUrl =
      'http://localhost:3000/tournaments'; // Replace with your API URL

  Future<void> fetchTournaments() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          tournaments = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch tournaments: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch tournaments')),
        );
      }
    } catch (e) {
      print('Error fetching tournaments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tournaments')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tournaments'),
      ),
      body: ListView.builder(
        itemCount: tournaments.length,
        itemBuilder: (context, index) {
          final tournament = tournaments[index]['tournament'];
          return ListTile(
            title: Text(tournament['name'] ?? 'No name'),
            subtitle: Text(tournament['description'] ?? 'No description'),
            trailing: IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(tournament['name']),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Type: ${tournament['tournament_type'] ?? 'Unknown'}'),
                        Text('URL: ${tournament['url'] ?? 'No URL'}'),
                        Text(
                            'Created At: ${tournament['created_at'] ?? 'Unknown'}'),
                        Text(
                            'Participants Count: ${tournament['participants_count'] ?? 'Unknown'}'),
                        SizedBox(height: 10),
                        if (tournament['live_image_url'] != null)
                          FutureBuilder(
                            future: fetchImage(tournament['live_image_url']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error loading image');
                              } else {
                                return Image.memory(snapshot.data as Uint8List);
                              }
                            },
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create tournament screen
          Navigator.pushNamed(context, '/create-tournament');
        },
        child: Icon(Icons.add),
        tooltip: 'Create Tournament',
      ),
    );
  }

  Future<Uint8List> fetchImage(String imageUrl) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/fetch-image?url=$imageUrl'));

      if (response.statusCode == 200) {
        // Check if response body is empty
        if (response.bodyBytes.isEmpty) {
          throw Exception('Empty response body');
        }

        return response.bodyBytes as Uint8List; // Explicit type assertion
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching image: $e');
      throw Exception('Failed to load image');
    }
  }
}
