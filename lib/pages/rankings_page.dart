import 'package:flutter/material.dart';
import 'package:beyblade/pages/data/injection_container.dart'; // Import sl and NavigationService
import 'data/navigation_service.dart';

class RankingsPage extends StatefulWidget {
  @override
  _RankingsPageState createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  List<Map<String, String>> rankings = [
    {'name': 'Blader A', 'rank': '1'},
    {'name': 'Blader B', 'rank': '2'},
    {'name': 'Blader C', 'rank': '3'},
    // Add more items here to simulate a large dataset
  ];

  int _currentPage = 0;
  int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _sortRankingsByName(); // Sort rankings by name initially
  }

  void _sortRankingsByName() {
    setState(() {
      rankings.sort((a, b) => a['name']!.compareTo(b['name']!));
      _currentPage = 0; // Reset to first page after sorting
    });
  }

  List<Map<String, String>> _getPaginatedRankings() {
    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    return rankings.sublist(
        start, end > rankings.length ? rankings.length : end);
  }

  void _nextPage() {
    if ((_currentPage + 1) * _itemsPerPage < rankings.length) {
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
        title: Text('Rankings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, // Changed to dark color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            sl<NavigationService>()
                .navigateTo('/home'); // Navigate to home page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'Top Bladers',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Changed to dark color
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _getPaginatedRankings().length,
                itemBuilder: (context, index) {
                  var ranking = _getPaginatedRankings()[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(ranking['rank']!),
                        backgroundColor: Colors.black, // Changed to dark color
                        foregroundColor: Colors.white,
                      ),
                      title: Text(ranking['name']!),
                      subtitle: Text('Rank: ${ranking['rank']}'),
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
                    backgroundColor: Colors.black, // Changed to dark color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child:
                      Text('Previous', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Changed to dark color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Next', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sl<NavigationService>().navigateTo(
                    '/profile'); // Example navigation using NavigationService
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Changed to dark color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 18),
              ),
              child:
                  Text('Go to Profile', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
