import 'package:beyblade/pages/agency_home_page.dart';
import 'package:beyblade/pages/judge_home_page.dart';
import 'package:beyblade/pages/news_page.dart';
import 'pages/sponsors_home_page.dart';
import 'package:beyblade/pages/upgrade_account_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

// Import your other pages
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/profile_page.dart';
import 'pages/home_page.dart';
import 'pages/create_club_page.dart';
import 'pages/rankings_page.dart';
import 'pages/tournament_page.dart';
import 'pages/join_club_page.dart';
import 'pages/club_detail_page.dart';
import 'pages/admin/admin_login_page.dart';
import 'pages/admin/admin_page.dart';
import 'pages/admin/news_management_page.dart';
import 'pages/organizer_page.dart';
import 'pages/organizer_login_page.dart';
import 'pages/organizer_register_page.dart';
import 'pages/create_tournament_screen.dart';
import 'pages/manage_tournaments_screen.dart';
import 'pages/news_page.dart';
// Import your local dependencies
import 'pages/data/injection_container.dart'; // Adjust the path as per your structure
import 'pages/data/navigation_service.dart';
import 'pages/data/home_view_model.dart';
import 'pages/sponsors_home_page.dart';
import 'pages/upgrade_account_page.dart';
import 'pages/judge_home_page.dart';
import 'pages/agency_home_page.dart';
import 'pages/create_agency_page.dart';
import 'pages/agency_profile.dart';
import 'pages/invite_players.dart';
import 'pages/invitations_dialog.dart';
import 'pages/invites_club_page.dart';
import 'pages/mail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBLRd6X2X7mZ_lEHlGZzv0A_H9S6L1jqxA",
        authDomain: "test123-7ff7e.firebaseapp.com",
        projectId: "test123-7ff7e",
        storageBucket: "test123-7ff7e.appspot.com",
        messagingSenderId: "498981798184",
        appId: "1:498981798184:web:3d567a05bd78108d5a901d",
        measurementId: "G-XJHHBQTNC6",
      ),
    );
    setupLocator(); // Initialize GetIt and setup NavigationService
    runApp(MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: MaterialApp(
        title: 'Flutter Firebase Auth',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/', // Set initial route
        routes: {
          '/': (context) => HomePage(),
          '/home': (context) => HomePage(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/profile': (context) => ProfilePage(),
          '/join_club': (context) => JoinClubPage(),
          '/club': (context) => JoinClubPage(),
          '/create_club': (context) => CreateClubPage(),
          '/rankings': (context) => RankingPage(),
          '/tournaments': (context) => TournamentsPage(),
          '/admin': (context) => AdminLoginPage(),
          '/admin_page': (context) => AdminPage(),
          '/organizer': (context) => OrganizerPage(),
          '/organizer_login': (context) => OrganizerLoginPage(),
          '/register_organizer': (context) => OrganizerRegisterPage(),
          '/news': (context) => NewsPage(),
          '/agencyhome': (context) => AgencyHomePage(),
          '/sponsorshome': (context) => SponsorsHomePage(),
          '/judgehome': (context) => JudgeHomePage(),
          '/upgrade': (context) => UpgradeAccountPage(),
          '/createagency': (context) => CreateAgencyDialog(),
          '/agencyprofile': (context) => AgencyProfilePage(),
          '/inviteplayers': (context) => InvitePlayersPage(),
          '/inviteclubs': (context) => InviteClubLeadersPage(),
          '/mail': (context) => MailPage(),
        },
        navigatorKey:
            sl<NavigationService>().navigatorKey, // Set navigatorKey from GetIt
      ),
    );
  }
}
