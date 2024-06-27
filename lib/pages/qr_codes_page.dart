import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class QrCodeDisplay extends StatelessWidget {
  final String imageUrl;

  QrCodeDisplay({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Display'),
      ),
      body: Center(
        child: imageUrl.isNotEmpty
            ? Image.network(imageUrl)
            : Text('Image URL is empty or invalid'),
      ),
    );
  }
}

class OrganizerPage extends StatefulWidget {
  @override
  _OrganizerPageState createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> getQrCodeImageUrl(String imageName) async {
    try {
      final ref = _storage.ref().child('qr_codes/$imageName.png');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error getting download URL: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            String imageUrl = await getQrCodeImageUrl('your_image_name_here');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QrCodeDisplay(imageUrl: imageUrl),
              ),
            );
          },
          child: Text('Show QR Code'),
        ),
      ),
    );
  }
}
