import 'package:flutter/material.dart';
import 'package:beyblade/pages/data/injection_container.dart'; // Import sl and NavigationService
import 'data/navigation_service.dart';

class RankingsPage extends StatefulWidget {
  @override
  _RankingsPageState createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  final List<Map<String, String>> _rankings = [
    {'name': 'Blader A', 'rank': '1'},
    {'name': 'Blader B', 'rank': '2'},
    {'name': 'Blader C', 'rank': '3'},
    // Add more items here to simulate a large dataset
  ];

  int _currentPage = 0;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _sortRankingsByName();
  }

  void _sortRankingsByName() {
    setState(() {
      _rankings.sort((a, b) => a['name']!.compareTo(b['name']!));
      _currentPage = 0;
    });
  }

  List<Map<String, String>> _getPaginatedRankings() {
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
          onPressed: () => sl<NavigationService>().navigateTo('/home'),
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
                        child: Text(ranking['rank']!),
                        backgroundColor: Colors.black,
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => sl<NavigationService>().navigateTo('/profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Go to Profile',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
