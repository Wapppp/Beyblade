import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No users found'),
            );
          }

          var userDocs = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('UID')),
                DataColumn(label: Text('Blader Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Actions')),
              ],
              rows: userDocs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(doc.id)),
                  DataCell(Text(data['blader_name'] ?? 'N/A')),
                  DataCell(Text(data['email'] ?? 'N/A')),
                  DataCell(Text(data['role'] ?? 'N/A')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => EditUserDialog(
                                userId: doc.id,
                                userData: data,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => DeleteUserDialog(
                                userId: doc.id,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  EditUserDialog({required this.userId, required this.userData});

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _bladerName;
  late String _email;
  late String _role;

  @override
  void initState() {
    super.initState();
    _bladerName = widget.userData['blader_name'] ?? '';
    _email = widget.userData['email'] ?? '';
    _role = widget.userData['role'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit User'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _bladerName,
              decoration: InputDecoration(labelText: 'Blader Name'),
              onSaved: (value) {
                _bladerName = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a blader name';
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: _email,
              decoration: InputDecoration(labelText: 'Email'),
              onSaved: (value) {
                _email = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: _role,
              decoration: InputDecoration(labelText: 'Role'),
              onSaved: (value) {
                _role = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a role';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .update({
                'blader_name': _bladerName,
                'email': _email,
                'role': _role,
              });
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class DeleteUserDialog extends StatelessWidget {
  final String userId;

  DeleteUserDialog({required this.userId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete User'),
      content: Text('Are you sure you want to delete this user?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .delete();
            Navigator.of(context).pop();
          },
          child: Text('Delete'),
        ),
      ],
    );
  }
}
