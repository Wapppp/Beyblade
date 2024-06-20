import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late UserDataSource _userDataSource;

  @override
  void initState() {
    super.initState();
    _userDataSource = UserDataSource(
      onEdit: _editUser,
      onDelete: _deleteUser,
    );
  }

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
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          _userDataSource.updateDocuments(snapshot.data!.docs);

          return SingleChildScrollView(
            child: PaginatedDataTable(
              header: Text('User Management'),
              columns: [
                DataColumn(label: Text('Blader Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Actions')),
              ],
              source: _userDataSource,
              rowsPerPage: 5,
              columnSpacing: 10,
              horizontalMargin: 20,
              showCheckboxColumn: false,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateUser,
        child: Icon(Icons.add),
      ),
    );
  }

  void _editUser(DocumentSnapshot document) {
    var userData = document.data() as Map<String, dynamic>;
    TextEditingController bladerNameController =
        TextEditingController(text: userData['blader_name']);
    TextEditingController emailController =
        TextEditingController(text: userData['email']);
    TextEditingController roleController =
        TextEditingController(text: userData['role']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bladerNameController,
                decoration: InputDecoration(labelText: 'Blader Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: roleController,
                decoration: InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _firestore.collection('users').doc(document.id).update({
                  'blader_name': bladerNameController.text,
                  'email': emailController.text,
                  'role': roleController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _firestore.collection('users').doc(document.id).delete();
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCreateUser() {
    TextEditingController bladerNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bladerNameController,
                decoration: InputDecoration(labelText: 'Blader Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: roleController,
                decoration: InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _firestore.collection('users').add({
                  'blader_name': bladerNameController.text,
                  'email': emailController.text,
                  'role': roleController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class UserDataSource extends DataTableSource {
  final Function(DocumentSnapshot) onEdit;
  final Function(DocumentSnapshot) onDelete;
  List<DocumentSnapshot> _documents = [];

  UserDataSource({
    required this.onEdit,
    required this.onDelete,
  });

  void updateDocuments(List<DocumentSnapshot> documents) {
    _documents = documents;
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    if (index >= _documents.length) return const DataRow(cells: []);
    var userData = _documents[index].data() as Map<String, dynamic>;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(userData['blader_name'] ?? 'No Blader Name')),
        DataCell(Text(userData['email'] ?? 'No Email')),
        DataCell(Text(userData['role'] ?? 'No Role')),
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                onEdit(_documents[index]);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                onDelete(_documents[index]);
              },
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _documents.length;

  @override
  int get selectedRowCount => 0;
}
