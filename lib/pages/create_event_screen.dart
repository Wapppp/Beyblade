import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String selectedType = 'single elimination';
  User? user = FirebaseAuth.instance.currentUser;
  String? qrCodeUrl; // Variable to hold the uploaded QR code URL
  DateTime? eventDateTime; // DateTime for the event

  final String apiUrl = 'http://localhost:3000/create-tournament';

  Future<void> createTournament() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not signed in')),
      );
      return;
    }

    final organizerData = await FirebaseFirestore.instance
        .collection('organizers')
        .doc(user!.uid)
        .get();

    if (!organizerData.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Organizer not found')),
      );
      return;
    }

    final tournamentData = {
      'tournament': {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'tournament_type': selectedType,
        'open_signup': true,
        'location': _locationController.text,
        'event_date_time': eventDateTime?.toIso8601String(), // Use null-aware operator
      }
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tournamentData),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final String tournamentId = responseBody['tournament']['id'].toString();

        await FirebaseFirestore.instance
            .collection('tournaments')
            .doc(tournamentId)
            .set({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'tournament_type': selectedType,
          'open_signup': true,
          'created_at': DateTime.now(),
          'challonge_id': tournamentId,
          'organizerId': user!.uid,
          'organizerName': organizerData['organizer_name'],
          'location': _locationController.text,
          'event_date_time': eventDateTime != null ? Timestamp.fromDate(eventDateTime!) : null, // Use null check and force unwrap
        });

        await _generateAndUploadQrCode(tournamentId); // Generate and upload QR code

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tournament created successfully')),
        );
        Navigator.pop(context);
      } else {
        print('Failed to create tournament: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create tournament')),
        );
      }
    } catch (e) {
      print('Error creating tournament: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating tournament')),
      );
    }
  }

  Future<void> _generateAndUploadQrCode(String tournamentId) async {
    try {
      final qrData =
          'Tournament ID: $tournamentId\nName: ${_nameController.text}';
      final painter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      final imageSize = 200.0;
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final size = Size(imageSize, imageSize);
      painter.paint(canvas, size);
      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(imageSize.toInt(), imageSize.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final storageRef =
          FirebaseStorage.instance.ref().child('qr_codes/$tournamentId.png');
      await storageRef.putData(buffer);

      qrCodeUrl = await storageRef.getDownloadURL();
      print('QR code uploaded to Firebase Storage: $qrCodeUrl');
    } catch (e) {
      print('Error generating or uploading QR code: $e');
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: eventDateTime ?? now,
      firstDate: DateTime(now.year),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(eventDateTime ?? now),
      );

      if (timePicked != null) {
        setState(() {
          eventDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Tournament'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tournament Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedType,
              onChanged: (newValue) {
                setState(() {
                  selectedType = newValue!;
                });
              },
              items: <String>['single elimination', 'double elimination']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(labelText: 'Tournament Type'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _selectDateTime(context),
              child: Text(eventDateTime == null
                  ? 'Select Event Date & Time'
                  : 'Selected: ${eventDateTime!.toLocal()}'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: createTournament,
              child: Text('Create Tournament'), 
            if (qrCodeUrl != null) ...[
              SizedBox(height: 20),
              Text('QR Code URL: $qrCodeUrl'),
            ],
          ],
        ),
      ),
    );
  }
}
