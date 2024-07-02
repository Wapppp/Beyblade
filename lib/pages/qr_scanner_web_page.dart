import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Import QR code scanner plugin
import 'package:firebase_storage/firebase_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScannerWebPage extends StatefulWidget {
  @override
  _QRScannerWebPageState createState() => _QRScannerWebPageState();
}

class _QRScannerWebPageState extends State<QRScannerWebPage> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text('Align QR code within the frame to scan.'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        isLoading = true;
      });
    });
  }

  Future<void> _uploadQRCodeToStorage(String qrData) async {
    try {
      // Create QR image and convert to byte data
      final imageSize = 200.0;
      final painter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final size = Size(imageSize, imageSize);
      painter.paint(canvas, size);
      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(
        imageSize.toInt(),
        imageSize.toInt(),
      );
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final buffer = byteData!.buffer.asUint8List();

      // Upload to Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref().child('qr_codes/$qrData.png');
      await storageRef.putData(buffer);

      // Handle successful upload
      print('QR Code uploaded to Firebase Storage.');

      // Optionally, display success message or navigate back
    } catch (e) {
      print('Error uploading QR Code to Firebase Storage: $e');
      // Handle error uploading to Firebase Storage
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
