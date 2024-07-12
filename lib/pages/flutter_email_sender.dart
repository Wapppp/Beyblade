import 'package:flutter_email_sender/flutter_email_sender.dart';

class EmailService {
  static Future<void> sendEmail({
    required String recipientEmail,
    required String subject,
    required String body,
  }) async {
    try {
      final Email email = Email(
        recipients: [recipientEmail],
        subject: subject,
        body: body,
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
      print('Email sent to $recipientEmail');
    } catch (e) {
      print('Error sending email: $e');
      throw e; // Throw the error to handle it in the UI or caller
    }
  }
}