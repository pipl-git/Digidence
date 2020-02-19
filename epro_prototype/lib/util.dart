import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Util {
  static void alert(BuildContext context, String msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Alert"),
            content: Text(msg),
            actions: [
              new FlatButton(
                child: const Text("Ok"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  static void snackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          Scaffold.of(context).removeCurrentSnackBar();
        },
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  static void toast(String msg) {
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_LONG);
  }

  static MaterialButton bottomButton(String text, VoidCallback onPressed) {
    return new RaisedButton(
      onPressed: onPressed,
      textColor: Colors.white,
      color: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0)),
      child: new Text(text),
    );
  }

  static Widget getProgressBar(double val) {
    return SizedBox(
        height: 3.0,
        child: LinearProgressIndicator(
            value: val, valueColor: AlwaysStoppedAnimation<Color>(Colors.black45), backgroundColor: Colors.black12));
  }

  static double smallSide(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return width > height ? height : width;
  }

  static EdgeInsets outerPadding(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var padding;
    if (width > height) {
      var gap = (width - height) / 2;
      padding = EdgeInsets.fromLTRB(gap + 20, 20, gap + 20, 20);
    } else {
      padding = EdgeInsets.all(20);
    }
    return padding;
  }

  static Future<Rslt> callApi(BuildContext context, String apiName, String methodName, Map<String, Object> data) async {
    if (1 > 2) {
      var r = Rslt();
      var dat;
      if (methodName == 'login') {
        dat = 1;
      } else if (methodName == 'retrieveCheckIn') {
        dat = {'other': 'Test Data'};
      }
      r.rc = 0;
      r.data = dat;
      return r;
    }

    String server = 'http://www.prescientinfotech.com/';
    var jsonStr = json.encode(data);
    var rslt = Rslt();
    try {
      final response = await http.post('$server/eProServer/api?apiName=$apiName&methodName=$methodName',
          headers: {"Content-Type": "text/plain"}, body: jsonStr);
      if (response.statusCode != 200) {
        rslt.rc = -1;
        rslt.msg = 'Server communication error. Errorcode: ${response.statusCode} body: ${response.body}';
      } else {
        jsonStr = response.body;
        var map = json.decode(jsonStr);
        rslt.rc = map['rc'];
        rslt.msg = map['msg'];
        rslt.data = map['data'];
      }
    } catch (ex) {
      rslt.rc = -1;
      rslt.msg = (ex.message != null && ex.message != '') ? ex.message : 'Server communication error';
    }
    if (rslt.rc != 0) {
      Util.snackBar(context, rslt.msg);
    }
    return rslt;
  }
}

class Rslt {
  int rc;
  String msg;
  dynamic data;
}
