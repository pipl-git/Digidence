import 'package:flutter/material.dart';

import 'util.dart';

class CheckInHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Welcome back! start your daily check-in',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      new GestureDetector(
        child: new Image.asset('image/check_in.png', width: 600),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CheckInPanel(checkInItem: ActivityData())),
          );
        },
      )
    ]);
  }
}

class CheckInPanel extends StatelessWidget {
  final CheckInItem checkInItem;

  CheckInPanel({this.checkInItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Check-In"),
        ),
        extendBody: true,
        body: checkInItem,
        bottomSheet: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20.0),
            child: GestureDetector(
                child: Text("skip",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                        color: Colors.black54)),
                onTap: () => checkInItem.onNext(true)),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Util.bottomButton("Back", checkInItem.onBack),
              Util.bottomButton("Next", () => checkInItem.onNext(false)),
            ],
          ),
        ]));
  }
}

abstract class CheckInItem extends StatelessWidget {
  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return getBody();
  }

  void onBack() {
    if (this is ActivityData) {
      Navigator.of(_context).pop();
    } else {
      Navigator.pushReplacement(
        _context,
        MaterialPageRoute(
            builder: (context) => CheckInPanel(checkInItem: getOnBack())),
      );
    }
  }

  void onNext(bool skip) {
    if (this is OtherData) {
      Navigator.of(_context).pop();
    } else {
      if (!skip) collectData();
      Navigator.pushReplacement(
        _context,
        MaterialPageRoute(
            builder: (context) => CheckInPanel(checkInItem: getOnNext())),
      );
    }
  }

  Widget getBody();

  CheckInItem getOnBack();

  CheckInItem getOnNext();

  void collectData();
}

class ActivityData extends CheckInItem {
  @override
  Widget getBody() {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(children: <Widget>[
          LinearProgressIndicator(
              value: .2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
              backgroundColor: Colors.black12),
          Text(
            '\r\nWhere you limited in doing either your work or other daily activities\r\n',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Util.actionButton("Not At All", () => {}),
          Util.actionButton("A Little", () => {}),
          Util.actionButton("Quite a Bit", () => {}),
          Util.actionButton("Very Much", () => {}),
        ]));
  }

  @override
  CheckInItem getOnBack() {
    return null;
  }

  @override
  CheckInItem getOnNext() {
    return SwellingData();
  }

  @override
  void collectData() {}
}

class SwellingData extends CheckInItem {
  @override
  Widget getBody() {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(children: <Widget>[
          LinearProgressIndicator(
              value: .4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
              backgroundColor: Colors.black12),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(_context).style,
              children: <TextSpan>[
                TextSpan(text: '\r\nHow often did you have'),
                TextSpan(
                    text: ' arm or leg swelling?\r\n',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Table(border: TableBorder.all(width: 1), children: <TableRow>[
            TableRow(children: <TableCell>[
              TableCell(
                child: Text('Never'),
              ),
              TableCell(
                child: Text(
                  '2',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              TableCell(
                child: Text('3'),
              ),
              TableCell(
                child: Text('4'),
              ),
              TableCell(
                child: Text('5'),
              ),
              TableCell(
                child: Text('Almost Constantly'),
              ),
            ]),
          ]),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(_context).style,
              children: <TextSpan>[
                TextSpan(text: '\r\nWhat was the severity of your'),
                TextSpan(
                    text: ' arm or leg swelling',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: " at it's"),
                TextSpan(
                    text: ' worst',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(_context).style,
              children: <TextSpan>[
                TextSpan(
                    text:
                        '\r\nHow much your arm or leg swelling intefere with your daily activities?'),
              ],
            ),
          ),
        ]));
  }

  @override
  CheckInItem getOnBack() {
    return ActivityData();
  }

  @override
  CheckInItem getOnNext() {
    return AttentionData();
  }

  @override
  void collectData() {}
}

class AttentionData extends CheckInItem {
  @override
  Widget getBody() {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(children: <Widget>[
          LinearProgressIndicator(
              value: .6,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
              backgroundColor: Colors.black12),
          Text(
            '\r\nI had to work very hard to pay attention or I would make a mistake\r\n',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Util.actionButton("Never", () => {}),
          Util.actionButton("Rarely (Once)", () => {}),
          Util.actionButton("Sometimes (2-3 times)", () => {}),
          Util.actionButton("Often (once a day)", () => {}),
          Util.actionButton("Very Often (several times a day)", () => {}),
        ]));
  }

  @override
  CheckInItem getOnBack() {
    return SwellingData();
  }

  @override
  CheckInItem getOnNext() {
    return OtherData();
  }

  @override
  void collectData() {}
}

class OtherData extends CheckInItem {
  @override
  Widget getBody() {
    return Center(child: Text('Other Data'));
  }

  @override
  CheckInItem getOnBack() {
    return SwellingData();
  }

  @override
  CheckInItem getOnNext() {
    return null;
  }

  @override
  void collectData() {}
}
