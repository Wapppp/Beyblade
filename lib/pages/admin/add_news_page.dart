import 'dart:html' as html; // Import html for web-specific functionalities
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl package for DateFormat

class AddNewsPage extends StatefulWidget {
  @override
  _AddNewsPageState createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _imageUrl; // Variable to hold the image URL after upload
  DateTime _selectedDate = DateTime.now(); // Selected publication date

  void _getImage() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*'; // Accept only image files
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();

      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((loadEndEvent) {
        setState(() {
          // Set the image URL directly from the reader result
          _imageUrl = reader.result as String?;
        });
      });
    });
  }

  void _addNews() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isNotEmpty && description.isNotEmpty && _imageUrl != null) {
      // Add news item to Firestore
      await _firestore.collection('news').add({
        'title': title,
        'description': description,
        'image': _imageUrl,
        'date': _selectedDate, // Include publication date
        // Add other fields as needed
      }).then((_) {
        // Clear text fields and image URL after successful addition
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _imageUrl = null;
          _selectedDate = DateTime.now(); // Reset selected date
        });
        Navigator.pop(context); // Close the add news page
      }).catchError((error) {
        print('Error adding news item: $error');
        // Handle error
      });
    } else {
      // Show error message or handle empty fields
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill all fields and select an image.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add News'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectDate(context), // Call date picker
              child: Text(
                  'Select Date: ${DateFormat('MM/dd/yyyy').format(_selectedDate)}'),
            ),
            SizedBox(height: 16),
            _imageUrl == null
                ? ElevatedButton(
                    onPressed: _getImage,
                    child: Text('Add Image'),
                  )
                : Image.network(
                    _imageUrl!,
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addNews,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
