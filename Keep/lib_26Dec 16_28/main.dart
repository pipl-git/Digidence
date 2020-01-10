import 'package:flutter/material.dart';

import 'checkin.dart';
import 'util.dart';

void main() => runApp(AppMain());

class AppMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
          appBar: AppBar(
            title: Text('ePro'),
          ),
          body: CheckInHome()),
    );
  }
}
