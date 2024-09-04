import 'package:app_iot/accidents%20_braking_page.dart';
import 'package:app_iot/home.dart';
import 'package:app_iot/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

double animatedPositionedLeftValue(int currentIndex, BuildContext context){
  switch(currentIndex){
    case 0:
      return MediaQuery.of(context).size.width / 100 * 8;
    case 1:
      return MediaQuery.of(context).size.width / 100 * 30.5;
    case 2:
      return MediaQuery.of(context).size.width / 100 * 52.5;
    case 3:
      return MediaQuery.of(context).size.width / 100 * 75;
    default:
      return 0;
  }
}

final List<Color> gradient = [
  Color(0XFF29E2FD).withOpacity(0.8),
  Color(0XFF29E2FD).withOpacity(0.5),
  Colors.transparent
];

List<Widget> screens = [
  UserPage(),
  AccidentBrakingPage(),
  ProfileScreen(),
];