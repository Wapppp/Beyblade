import 'package:flutter/material.dart';

class InvitationsDialog extends StatefulWidget {
  final List<Map<String, dynamic>> invitations;
  final Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>) onAccept;

  InvitationsDialog({
    Key? key,
    required this.invitations,
    required this.onDelete,
    required this.onAccept,
  }) : super(key: key);

  @override
  _InvitationsDialogState createState() => _InvitationsDialogState();
}

class _InvitationsDialogState extends State<InvitationsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Invitations'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.invitations.map((invitation) {
            return ListTile(
              title: Text('Invitation from ${invitation['agency_name']}'),
              subtitle: Text('Contact: ${invitation['agency_email']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      widget.onAccept(invitation); // Handle accept invitation
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      widget.onDelete(invitation); // Handle delete invitation
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}