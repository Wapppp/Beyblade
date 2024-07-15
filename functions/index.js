const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();
const firestore = admin.firestore();

// Configure the email transport using the default SMTP transport
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'ralpheco6@gmail.com',
    pass: 'Rapeco123',
  },
});

exports.sendInvitationEmail = functions.firestore
  .document('invitations/{invitationId}')
  .onCreate(async (snap, context) => {
    const invitation = snap.data();
    const playerId = invitation.player_id;

    try {
      const playerSnapshot = await firestore.collection('users').doc(playerId).get();
      const playerData = playerSnapshot.data();

      if (playerData && playerData.email) {
        const mailOptions = {
          from: 'ralpheco6@gmail.com',
          to: playerData.email,
          subject: 'You have a new invitation',
          text: `Hello ${playerData.blader_name},\n\nYou have been invited to join an agency or sponsor. Please log in to your account for more details.\n\nBest regards,\nBeybladeX Team`,
        };

        await transporter.sendMail(mailOptions);
        console.log('Email sent to:', playerData.email);
      }
    } catch (error) {
      console.error('Error sending email:', error);
    }
  });