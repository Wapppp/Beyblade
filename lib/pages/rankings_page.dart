import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingsPage extends StatefulWidget {
  @override
  _RankingsPageState createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<Map<String, dynamic>> _rankings;
  int _currentPage = 0;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _rankings = [];
    _fetchRankings();
  }

  void _fetchRankings() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      List<Map<String, dynamic>> users = snapshot.docs.map((doc) {
        return {
          'name': doc['blader_name'] ?? 'No Name',
          'won': doc['won'] ?? 0,
          'lost': doc['lost'] ?? 0,
        };
      }).toList();

      // Sort users by 'won' descending and 'lost' ascending
      users.sort((a, b) {
        if (a['won'] != b['won']) {
          return b['won'].compareTo(a['won']); // Sort by won descending
        } else {
          return a['lost'].compareTo(
              b['lost']); // If won is the same, sort by lost ascending
        }
      });

      setState(() {
        _rankings = users;
      });
    } catch (e) {
      print('Error fetching rankings: $e');
    }
  }

  List<Map<String, dynamic>> _getPaginatedRankings() {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, _rankings.length);
    return _rankings.sublist(start, end);
  }

  void _nextPage() {
    if ((_currentPage + 1) * _itemsPerPage < _rankings.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Top Bladers',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _getPaginatedRankings().length,
                itemBuilder: (context, index) {
                  final ranking = _getPaginatedRankings()[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text((index + 1).toString()),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      title: Text(ranking['name']),
                      subtitle: Text(
                          'Won: ${ranking['won']}, Lost: ${ranking['lost']}'),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Previous',
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child:
                      const Text('Next', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
