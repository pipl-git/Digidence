import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'epro_widget.dart';
import 'util.dart';

typedef NextPanel(BuildContext context);

class CheckInData {
  int usrId;
  int activity = 0;
  int attention = 0;
  int swelling_1 = 0;
  int swelling_2 = 0;
  int swelling_3 = 0;
  int pain = 0;
  String other;

  Future<Rslt> init(BuildContext context, int id) async {
    usrId = id;

    var formatter = new DateFormat('yyyyMMdd');
    String dt = formatter.format(new DateTime.now());
    var data = {'usr_id': usrId, 'dt': dt};
    var rslt =
        await Util.callApi(context, 'AppsCommon', 'retrieveCheckIn', data);
    if (rslt.rc == 0 && rslt.data != null) {
      activity = rslt.data['activity'] ?? 0;
      attention = rslt.data['attention'] ?? 0;
      swelling_1 = rslt.data['swelling_1'] ?? 0;
      swelling_2 = rslt.data['swelling_2'] ?? 0;
      swelling_3 = rslt.data['swelling_3'] ?? 0;
      pain = rslt.data['pain'] ?? 0;
      other = rslt.data['other'];
    }
    return rslt;
  }

  Future<Rslt> save(BuildContext context) async {
    var formatter = new DateFormat('yyyyMMdd');
    String dt = formatter.format(new DateTime.now());
    var data = {
      'usr_id': usrId,
      'dt': dt,
      'activity': activity,
      'attention': attention,
      'swelling_1': swelling_1,
      'swelling_2': swelling_2,
      'swelling_3': swelling_3,
      'other': other,
      'pain': pain
    };

    var rslt = await Util.callApi(context, 'AppsCommon', 'insertCheckIn', data);
    return rslt;
  }
}

class CheckInHome extends StatelessWidget {
  CheckInHome({Key key, this.checkInData}) : super(key: key);
  final CheckInData checkInData;

  @override
  Widget build(BuildContext context) {
    var size = Util.smallSide(context) * 0.75;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('ePro'),
        ),
        body: SingleChildScrollView(
            padding: Util.outerPadding(context),
            child: Column(children: <Widget>[
              Center(
                  child: Text(
                'Welcome back! start your daily check-in',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )),
              SizedBox(height: 50),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return CheckInPanel(checkInData: checkInData);
                      }),
                    );
                  },
                  child: Container(
                    decoration: new BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                        )
                      ],
                    ),
                    child: new Image.asset('image/check_in.png',
                        width: size, height: size, fit: BoxFit.fill),
                  ))
            ])));
  }
}

class CheckInPanel extends StatefulWidget {
  CheckInPanel({Key key, this.checkInData}) : super(key: key);
  final CheckInData checkInData;

  @override
  _CheckInPanelState createState() {
    return _CheckInPanelState();
  }
}

class _CheckInPanelState extends State<CheckInPanel> {
  int currPanel = 1;

  skip(BuildContext context) {
    next(context);
  }

  back(BuildContext context) {
    if (currPanel == 1) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        currPanel--;
      });
    }
  }

  next(BuildContext context) {
    if (currPanel < 5) {
      setState(() {
        currPanel++;
      });
    } else {
      done(context);
    }
  }

  done(BuildContext context) {
    var checkInData = widget.checkInData;
    var onPressed = () async {
      var rslt = await checkInData.save(context);
      if (rslt.rc == 0) {
        currPanel = 1;
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    };

    var msg =
        'You have completed your check-in for the day. Come back tomorrow for another check-in';
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Check-In Complete'),
            content: Text(msg),
            actions: [
              new FlatButton(
                child: const Text('Ok'),
                onPressed: onPressed,
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var checkInData = widget.checkInData;
    Widget body;
    if (currPanel == 1) {
      body = ActivityData(checkInData, next);
    } else if (currPanel == 2) {
      body = SwellingData(checkInData, next);
    } else if (currPanel == 3) {
      body = AttentionData(checkInData, next);
    } else if (currPanel == 4) {
      body = OtherData(checkInData, next);
    } else if (currPanel == 5) {
      body = PainData(checkInData, next);
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: true,
          leading: BackButton(),
          title: Text('Check-In'),
        ),
        body: SingleChildScrollView(
            padding: Util.outerPadding(context), child: body),
        bottomNavigationBar:
            Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          currPanel < 5
              ? GestureDetector(
                  child: Text('skip',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                          color: Colors.black54)),
                  onTap: () {
                    skip(context);
                  })
              : Container(),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Util.bottomButton('Back', () {
                back(context);
              }),
              currPanel < 5
                  ? Util.bottomButton('Next', () {
                      next(context);
                    })
                  : Util.bottomButton('Finish', () {
                      done(context);
                    }),
            ],
          ),
        ]));
  }
}

class ActivityData extends StatelessWidget {
  ActivityData(this.checkInData, this.onNext);
  final CheckInData checkInData;
  final NextPanel onNext;

  @override
  Widget build(BuildContext context) {
    var buttons = ['Not At All', 'A Little', 'Quite a Bit', 'Very Much'];
    return Column(children: <Widget>[
      Util.getProgressBar(.2),
      Text(
        '\r\nWhere you limited in doing either your work or other daily activities\r\n',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      VerticalButtonsPanel(
        buttons: buttons,
        selectedButton: checkInData.activity,
        onPressed: (btnNo) {
          checkInData.activity = btnNo;
          onNext(context);
        },
      )
    ]);
  }
}

class AttentionData extends StatelessWidget {
  AttentionData(this.checkInData, this.onNext);
  final CheckInData checkInData;
  final NextPanel onNext;

  @override
  Widget build(BuildContext context) {
    var buttons = [
      'Never',
      'Rarely (Once)',
      'Sometimes (2-3 times)',
      'Often (once a day)',
      'Very Often (several times a day)'
    ];
    return Column(children: <Widget>[
      Util.getProgressBar(.6),
      Text(
        '\r\nI had to work very hard to pay attention or I would make a mistake\r\n',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      VerticalButtonsPanel(
        buttons: buttons,
        selectedButton: checkInData.attention,
        onPressed: (btnNo) {
          checkInData.attention = btnNo;
          onNext(context);
        },
      )
    ]);
  }
}

class SwellingData extends StatelessWidget {
  SwellingData(this.checkInData, this.onNext);
  final CheckInData checkInData;
  final NextPanel onNext;

  final btns_1 = [
    [1, 'NEVER', 'Never'],
    [2, '1', 'Rarely'],
    [3, '2', 'Occasionally'],
    [4, '3', 'Some Times'],
    [5, '4', 'Frequently'],
    [6, 'ALMOST CONSTANTLY', 'Always']
  ];
  final btns_2 = [
    [1, 'NONE', 'None'],
    [2, '1', 'Very Mild'],
    [3, '2', 'Mild'],
    [4, '3', 'Medium'],
    [5, '4', 'Severe'],
    [6, 'VERY SEVERE', 'Very Severe']
  ];
  final btns_3 = [
    [1, 'NOT AT ALL', 'Not At All'],
    [2, '1', 'Very Little'],
    [3, '2', 'Little'],
    [4, '3', 'Somewhat'],
    [5, '4', 'Lot'],
    [6, 'VERY MUCH', 'Very Much']
  ];

  @override
  Widget build(BuildContext context) {
    final header_1 = RichText(
        text: TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: <TextSpan>[
        TextSpan(text: '\r\nHow often did you have'),
        TextSpan(
            text: ' arm or leg swelling?\r\n',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ));

    final header_2 = RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(text: '\r\nWhat was the severity of your'),
          TextSpan(
              text: ' arm or leg swelling',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: " at it's"),
          TextSpan(
              text: ' worst', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );

    final header_3 = RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
              text:
                  '\r\nHow much your arm or leg swelling intefere with your daily activities?'),
        ],
      ),
    );

    return Column(children: <Widget>[
      Util.getProgressBar(.4),
      header_1,
      HorizontalButtonsPanel(
        buttons: btns_1,
        selectedButton: checkInData.swelling_1,
        onPressed: (btnNo) {
          checkInData.swelling_1 = btnNo;
        },
      ),
      header_2,
      HorizontalButtonsPanel(
        buttons: btns_2,
        selectedButton: checkInData.swelling_2,
        onPressed: (btnNo) {
          checkInData.swelling_2 = btnNo;
        },
      ),
      header_3,
      HorizontalButtonsPanel(
        buttons: btns_3,
        selectedButton: checkInData.swelling_3,
        onPressed: (btnNo) {
          checkInData.swelling_3 = btnNo;
        },
      ),
    ]);
  }
}

class OtherData extends StatelessWidget {
  OtherData(this.checkInData, this.onNext);
  final CheckInData checkInData;
  final NextPanel onNext;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Util.getProgressBar(.8),
      Text(
        '\r\nDo you have anything else you would like to share with us today?\r\n',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextFormField(
          initialValue: checkInData.other,
          autofocus: true,
          maxLines: 7,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          onChanged: (text) {
            checkInData.other = text;
          },
          onFieldSubmitted: (text) {
            checkInData.other = text;
            onNext(context);
          }),
    ]);
  }
}

class PainData extends StatelessWidget {
  PainData(this.checkInData, this.onNext);
  final CheckInData checkInData;
  final NextPanel onNext;

  final labels = [
    'None',
    "Sometimes",
    "Bearable",
    "Mild",
    "Severe",
    "Can't be ignored for more than 30 minutes",
    "Better after pain killer",
    "Relapse after 1 hour",
    "Need emergency medical assistance",
    "Visit by nurse is required",
    "Visit to hospital is required"
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Util.getProgressBar(1),
      SizedBox(height: 20),
      Text(
        '\r\nRate your pain in last 24 hours.\r\n',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      SizedBox(height: 50),
      StatefulSlider(
        val: checkInData.pain,
        labels: labels,
        onChanged: (vl) {
          checkInData.pain = vl;
        },
      )
    ]);
  }
}
