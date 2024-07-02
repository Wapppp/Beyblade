
import 'package:flutter/material.dart';


class UserProfile {
  final String bladerName;
  final int won;
  final int lost;
  final int points;
  final String profilePicture;

  UserProfile({
    required this.bladerName,
    required this.won,
    required this.lost,
    required this.points,
    required this.profilePicture,
  });
}
