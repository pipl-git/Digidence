import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'util.dart';

/*
  Password field with visible eye icon.
*/
class PasswordField extends StatefulWidget {
  PasswordField(
      {Key key,
      this.labelText,
      this.hintText,
      @required this.editingController})
      : super(key: key);
  final TextEditingController editingController;
  final String labelText;
  final String hintText;
  @override
  PasswordFieldState createState() =>
      PasswordFieldState(editingController: editingController);
}

class PasswordFieldState extends State<PasswordField> {
  PasswordFieldState({this.editingController});
  final TextEditingController editingController;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      controller: editingController,
      style: TextStyle(fontSize: 18.0),
      decoration: InputDecoration(
        labelText: widget.labelText,
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: widget.hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}

/*
  Stateful Checkbox. Remembers checked or unchecked.
*/
class StatefulCheckBox extends StatefulWidget {
  StatefulCheckBox({Key key, this.text, this.selected}) : super(key: key);
  final String text;
  final bool selected;
  @override
  StatefulCheckBoxState createState() => StatefulCheckBoxState(selected);
}

class StatefulCheckBoxState extends State<StatefulCheckBox> {
  StatefulCheckBoxState(this.selected) : super();
  bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Checkbox(
            value: selected,
            onChanged: (val) {
              setState(() {
                selected = val;
              });
            }),
        Text(widget.text),
      ],
    );
  }
}

/*
  Stateful Checkbox. Remembers checked or unchecked.
*/
class StatefulSlider extends StatefulWidget {
  StatefulSlider({Key key, this.val, this.labels, this.onChanged})
      : super(key: key);
  final ValueChanged<int> onChanged;
  final int val;
  final List<String> labels;

  @override
  StatefulSliderState createState() => StatefulSliderState(val: val);
}

class StatefulSliderState extends State<StatefulSlider> {
  StatefulSliderState({this.val}) : super();
  int val;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text(widget.labels[val]),
      Row(children: <Widget>[
        Text('0'),
        Expanded(
            child: Slider(
          value: val.toDouble(),
          min: 0,
          max: (widget.labels.length - 1).toDouble(),
          label: val.toString(),
          divisions: (widget.labels.length - 1),
          onChanged: (vl) {
            setState(() {
              val = vl.toInt();
              widget.onChanged(val);
            });
          },
        )),
        Text((widget.labels.length - 1).toString()),
      ]),
      Text(val.toString()),
    ]);
  }
}

/*
  Button with CircularProgress indicator and async callback.
*/
class ButtonWithCircularProgress extends StatefulWidget {
  ButtonWithCircularProgress({Key key, this.text, this.onPressed})
      : super(key: key);
  final String text;
  final AsyncCallback onPressed;

  @override
  ButtonWithCircularProgressState createState() {
    return ButtonWithCircularProgressState();
  }
}

class ButtonWithCircularProgressState
    extends State<ButtonWithCircularProgress> {
  var loading = false;
  @override
  Widget build(BuildContext context) {
    var button = Material(
      borderRadius: BorderRadius.circular(10.0),
      color: loading ? Colors.black45 : Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: loading
            ? null
            : () async {
                setState(() {
                  loading = true;
                });
                await widget.onPressed();
                setState(() {
                  loading = false;
                });
              },
        child: Text(widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold)),
      ),
    );

    return loading
        ? Column(children: <Widget>[
            button,
            SizedBox(height: 20),
            CircularProgressIndicator()
          ])
        : button;
  }
}

/*
  Vertical buttons panel. buttons bahaves like radio buttons.
*/
class VerticalButtonsPanel extends StatefulWidget {
  VerticalButtonsPanel(
      {Key key, this.buttons, this.selectedButton, this.onPressed})
      : super(key: key);
  final int selectedButton;
  final List<String> buttons;
  final ValueChanged<int> onPressed;

  @override
  VerticalButtonsPanelState createState() {
    return VerticalButtonsPanelState(selectedButton);
  }
}

class VerticalButtonsPanelState extends State<VerticalButtonsPanel> {
  VerticalButtonsPanelState(this.selectedButton) : super();
  int selectedButton;

  @override
  Widget build(BuildContext context) {
    var buttons = <Widget>[];
    for (var i = 1; i <= widget.buttons.length; i++) {
      var text = widget.buttons[i - 1];
      buttons.add(SizedBox(
          width: double.infinity,
          child: OutlineButton(
            onPressed: () {
              setState(() {
                selectedButton = i;
              });
              widget.onPressed(selectedButton);
            },
            textColor: Colors.black54,
            color: Colors.white,
            borderSide: widget.selectedButton == i
                ? BorderSide(color: const Color(0xffb5a2dc), width: 2)
                : null,
            child: new Text(text),
          )));
    }

    return Column(children: buttons);
  }
}

/*
  Horizontal Buttons with Text at the bottom of button.
*/
class HorizontalButtonsPanel extends StatefulWidget {
  HorizontalButtonsPanel(
      {Key key, this.buttons, this.selectedButton, this.onPressed})
      : super(key: key);
  final int selectedButton;
  final List<List<Object>> buttons;
  final ValueChanged<int> onPressed;

  @override
  HorizontalButtonsPanelState createState() {
    return HorizontalButtonsPanelState(selectedButton);
  }
}

class HorizontalButtonsPanelState extends State<HorizontalButtonsPanel> {
  HorizontalButtonsPanelState(this.selectedButton) : super();
  int selectedButton;

  @override
  Widget build(BuildContext context) {
    List btns = widget.buttons;

    const int spacerFlex = 1;
    const int smallBtnFlex = 20;
    const int largeBtnFlex = 25;

    var btnList = new List<Widget>();
    int activeBtnCenter = 0;
    int totalFlex = 0;
    for (var i = 1; i <= btns.length; i++) {
      var btn = btns[i - 1];
      btnList.add(Spacer(flex: spacerFlex));
      int btnFlex = i == 0 || i == 5 ? largeBtnFlex : smallBtnFlex;

      String btnText = btn[1];
      Text txt = Text(btnText,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(fontSize: btnText.length == 1 ? 16 : 7));

      Border border;
      BoxDecoration decoration;
      if (i == selectedButton) {
        border = Border.all(color: const Color(0xffb5a2dc), width: 3);
        decoration = BoxDecoration(
            border: border,
            color: Colors.black12,
            borderRadius: new BorderRadius.all(Radius.circular(10.0)));
      } else {
        border = Border.all(color: Colors.black12, width: 1);
        decoration = BoxDecoration(
            border: border,
            color: Colors.black12,
            borderRadius: new BorderRadius.all(Radius.circular(10.0)));
      }

      var btnHeight = Util.smallSide(context) / 10;
      var flexible = Flexible(
          fit: FlexFit.loose,
          flex: btnFlex,
          child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedButton = i;
                });
                widget.onPressed(selectedButton);
              },
              child: Container(
                  margin: const EdgeInsets.all(5.0),
                  height: btnHeight,
                  child: Center(
                    child: (txt),
                  ),
                  decoration: decoration)));

      btnList.add(flexible);
      if (i <= selectedButton) activeBtnCenter += spacerFlex;
      if (i < selectedButton) activeBtnCenter += btnFlex;
      if (i == selectedButton) activeBtnCenter += (btnFlex / 2).round();
      totalFlex += spacerFlex + btnFlex;
    }
    btnList.add(Spacer(flex: spacerFlex));
    totalFlex += spacerFlex;

    var btnSelTxt;

    String text = selectedButton > 0 ? btns[selectedButton - 1][2] : ' ';
    var txt = Text(text,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xffb5a2dc)));

    if (selectedButton == 1) {
      if (text.length > 6) {
        btnSelTxt = Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[txt]);
      } else {
        int txtFlex = activeBtnCenter * 2;
        int endFlex = totalFlex - txtFlex;
        btnSelTxt =
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Flexible(flex: (txtFlex), child: Center(child: txt)),
          Spacer(flex: endFlex),
        ]);
      }
    } else if (selectedButton == btns.length) {
      btnSelTxt = Row(
          mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[txt]);
    } else {
      int txtFlex = 70;
      int startFlex = activeBtnCenter - (txtFlex / 2).round();
      int endFlex = totalFlex - startFlex - txtFlex;
      if (startFlex < 0) startFlex = 1;
      if (endFlex < 0) endFlex = 1;

      btnSelTxt = Row(children: <Widget>[
        Spacer(flex: startFlex),
        Flexible(flex: (txtFlex), child: Center(child: txt)),
        Spacer(flex: endFlex),
      ]);
    }

    return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(width: 3, color: Colors.black38),
            borderRadius: new BorderRadius.all(Radius.circular(10.0))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IntrinsicHeight(
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: btnList)),
              btnSelTxt
            ]));
  }
}
