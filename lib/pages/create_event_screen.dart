import 'package:flutter/material.dart';

class TournamentEvent {
  final String name;
  final DateTime dateAndTime; // Changed to DateTime for combined date and time
  final String location;
  final String description;
  final String organizerId;

  TournamentEvent({
    required this.name,
    required this.dateAndTime,
    required this.location,
    required this.description,
    required this.organizerId,
  });
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
              onPressed: () {
                TournamentEvent event = TournamentEvent(
                  name: nameController.text,
                  dateAndTime: DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  ),
                  location: locationController.text,
                  description: descriptionController.text,
                  organizerId: widget.organizerId,
                );
                widget.onEventCreated(event);
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
          ],
        ),
      ),
    );
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
}
