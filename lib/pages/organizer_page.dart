import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizerPage extends StatefulWidget {
  @override
  _OrganizerPageState createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Organizer Page',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber.shade600,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.amber.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/150'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Organizer Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.event, color: Colors.amber.shade600),
              title: Text('Create an Event',
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreateEventScreen(onEventCreated: addEvent)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: Colors.amber.shade600),
              title: Text('Organizer Dashboard',
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Organizer Dashboard tapped')),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.black87,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to the Organizer Page!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade600,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Expanded(
<<<<<<< HEAD
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tournaments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.white)),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text('No tournaments available',
                              style: TextStyle(color: Colors.white)),
                        );
                      }

                      final events = snapshot.data!.docs.map((doc) {
                        return TournamentEvent(
                          name: doc['name'],
                          date: doc['date'],
                          location: doc['location'],
                          description: doc['description'],
                        );
                      }).toList();

                      return DataTable(
                        columns: [
                          DataColumn(
                              label: Text('Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Date',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Location',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Description',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                        ],
                        rows: events
                            .map((event) => DataRow(
                                  cells: [
                                    DataCell(Text(event.name,
                                        style: TextStyle(color: Colors.white))),
                                    DataCell(Text(event.date,
                                        style: TextStyle(color: Colors.white))),
                                    DataCell(Text(event.location,
                                        style: TextStyle(color: Colors.white))),
                                    DataCell(Text(event.description,
                                        style: TextStyle(color: Colors.white))),
                                  ],
                                ))
                            .toList(),
                      );
                    },
=======
                  child: DataTable(
                    columns: [
                      DataColumn(
                          label: Text('Name',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Date',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Location',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Description',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: events
                        .map((event) => DataRow(
                              cells: [
                                DataCell(Text(event.name,
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(event.date,
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(event.location,
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(event.description,
                                    style: TextStyle(color: Colors.white))),
                              ],
                            ))
                        .toList(),
>>>>>>> e05f89175013079da06c6d93b90f782689a0e6b1
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addEvent(TournamentEvent event) {
    FirebaseFirestore.instance.collection('tournaments').add({
      'name': event.name,
      'date': event.date,
      'location': event.location,
      'description': event.description,
    }).then((_) {
      // Optionally show a success message or perform other actions
    }).catchError((error) {
      // Handle any errors
      print('Error adding event: $error');
    });
  }
}

class TournamentEvent {
  final String name;
  final String date;
  final String location;
  final String description;

  TournamentEvent({
    required this.name,
    required this.date,
    required this.location,
    required this.description,
  });
}

class CreateEventScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final Function(TournamentEvent) onEventCreated;

  CreateEventScreen({required this.onEventCreated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Tournament'),
        backgroundColor: Colors.amber.shade600,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Organize a Tournament Event',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.grey,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Tournament Name',
                hintText: 'Enter tournament name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'Enter tournament date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'Enter tournament location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter tournament description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                TournamentEvent event = TournamentEvent(
                  name: nameController.text,
                  date: dateController.text,
                  location: locationController.text,
                  description: descriptionController.text,
                );

                onEventCreated(event);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tournament Event Created')),
                );

                Navigator.pop(context);
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.amber.shade600),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(vertical: 16),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                elevation: MaterialStateProperty.all<double>(8),
              ),
              child: Text(
                'Create Tournament',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
