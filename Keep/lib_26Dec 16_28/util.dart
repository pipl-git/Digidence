import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  static void toast(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  static MaterialButton bottomButton(String text, VoidCallback onPressed) {
    return new RaisedButton(
      onPressed: onPressed,
      textColor: Colors.white,
      color: Colors.black45,
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0)),
      child: new Text(text),
    );
  }

  static SizedBox actionButton(String text, VoidCallback onPressed) {
    return SizedBox(
        width: double.infinity,
        child: OutlineButton(
          onPressed: onPressed,
          textColor: Colors.black54,
          color: Colors.white,
          child: new Text(text),
        ));
  }
}
