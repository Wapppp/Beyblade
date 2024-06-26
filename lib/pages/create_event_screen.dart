import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CreateEventScreen(
        onEventCreated: (event) {
          // handle event creation
        },
        organizerId: 'organizerId',
      ),
    );
  }
}

class TournamentEvent {
  final String name;
  final DateTime dateAndTime;
  final Duration duration;
  final String location;
  final String description;
  final String organizerId;

  TournamentEvent({
    required this.name,
    required this.dateAndTime,
    required this.duration,
    required this.location,
    required this.description,
    required this.organizerId,
  });

  String getStatus() {
    final now = DateTime.now();
    final tournamentEnd = dateAndTime.add(duration);

    if (dateAndTime.isAfter(now)) {
      return 'Upcoming';
    } else if (dateAndTime.isBefore(now) && tournamentEnd.isAfter(now)) {
      return 'Ongoing';
    } else if (tournamentEnd.isBefore(now)) {
      return 'Ended';
    } else {
      return 'Started';
    }
  }
}

class CreateEventScreen extends StatefulWidget {
  final Function(TournamentEvent) onEventCreated;
  final String organizerId;

  CreateEventScreen({
    required this.onEventCreated,
    required this.organizerId,
  });

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController nameController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Duration selectedDuration = Duration(hours: 2);
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Tournament')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Tournament Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            _buildDateTimePicker(),
            SizedBox(height: 12),
            _buildDurationPicker(),
            SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                TournamentEvent event = TournamentEvent(
                  name: nameController.text,
                  dateAndTime: DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  ),
                  duration: selectedDuration,
                  location: locationController.text,
                  description: descriptionController.text,
                  organizerId: widget.organizerId,
                );

                widget.onEventCreated(event);
                await _saveEventToFirestore(event);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('Create Tournament', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
            Text(
              'Status: ${_getEventStatus()}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _getEventStatus() {
    TournamentEvent event = TournamentEvent(
      name: nameController.text,
      dateAndTime: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
      duration: selectedDuration,
      location: locationController.text,
      description: descriptionController.text,
      organizerId: widget.organizerId,
    );
    return event.getStatus();
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date and Time',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${selectedTime.format(context)}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDuration(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Duration (hours)',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${selectedDuration.inHours} hours',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _selectDuration(BuildContext context) async {
    final Duration? picked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Duration'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, Duration(hours: 1)),
              child: Text('1 hour'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, Duration(hours: 2)),
              child: Text('2 hours'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, Duration(hours: 3)),
              child: Text('3 hours'),
            ),
            // Add more options as needed
          ],
        );
      },
    );
    if (picked != null && picked != selectedDuration) {
      setState(() {
        selectedDuration = picked;
      });
    }
  }

  Future<void> _saveEventToFirestore(TournamentEvent event) async {
    final docRef = FirebaseFirestore.instance.collection('events').doc();
    await docRef.set({
      'name': event.name,
      'date': event.dateAndTime,
      'duration': event.duration.inMilliseconds,
      'location': event.location,
      'description': event.description,
      'organizerId': event.organizerId,
      'status': event.getStatus(),
    });

    // Generate and upload QR code
    await _generateAndUploadQrCode(docRef.id, event);
  }

  Future<void> _generateAndUploadQrCode(
      String eventId, TournamentEvent event) async {
    try {
      final qrData =
          'Event ID: $eventId\nEvent Name: ${event.name}\nOrganizer: ${event.organizerId}';
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
          FirebaseStorage.instance.ref().child('qr_codes/$eventId.png');
      await storageRef.putData(buffer);

      print('QR code uploaded to Firebase Storage');
    } catch (e) {
      print('Error generating or uploading QR code: $e');
      // Handle
    }
  }
}
