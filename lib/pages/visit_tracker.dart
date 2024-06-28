import 'package:cloud_firestore/cloud_firestore.dart';

class VisitTracker {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> trackVisit(Map<String, dynamic> player) async {
    try {
      // Example: Store player's visit in a 'visits' collection
      await _firestore.collection('visits').add({
        'blader_name': player['blader_name'],
        'visit_time': DateTime.now(),
        // Add more fields as needed to track the visit
      });
      print('Visit tracked successfully.');
    } catch (e) {
      print('Error tracking visit: $e');
    }
  }
}