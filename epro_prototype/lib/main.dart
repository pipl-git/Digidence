import 'package:flutter/material.dart';

import 'login.dart';
import 'checkin.dart';

void main() => runApp(AppMain());

class AppMain extends StatefulWidget {
  @override
  _AppMainState createState() => _AppMainState();
}

class _AppMainState extends State<AppMain> {
  bool loggedIn = false;
  CheckInData checkInData;

  onLoggedin(CheckInData data) {
    checkInData = data;
    setState(() {
      loggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: loggedIn
            ? CheckInHome(checkInData: checkInData)
            : LoginMainPage(onLoggedin: onLoggedin));
  }
}
