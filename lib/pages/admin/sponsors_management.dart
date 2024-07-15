import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SponsorsManagementPage extends StatefulWidget {
  @override
  _SponsorsManagementPageState createState() => _SponsorsManagementPageState();
}

class _SponsorsManagementPageState extends State<SponsorsManagementPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addSponsor() async {
    String name = _nameController.text.trim();
    String contact = _contactController.text.trim();

    if (name.isEmpty || contact.isEmpty) {
      // Show error message or handle empty fields
      return;
    }

    try {
      await _firestore.collection('sponsors').add({
        'name': name,
        'contact': contact,
      });

      // Clear input fields after successful submission
      _nameController.clear();
      _contactController.clear();

      // Show success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sponsor added successfully')),
      );
    } catch (e) {
      // Handle error
      print('Error adding sponsor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add sponsor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sponsors Management', style: TextStyle(color: Colors.grey[300])),
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
      body: Container(
        padding: EdgeInsets.all(20),
        color: Colors.grey[900],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Sponsor Name',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contactController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Contact Details',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSponsor,
              child: Text('Add Sponsor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}