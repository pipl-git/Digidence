import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'epro_widget.dart';
import 'util.dart';
import 'checkin.dart';

class LoginMainPage extends StatefulWidget {
  LoginMainPage({Key key, this.onLoggedin}) : super(key: key);
  final ValueChanged<CheckInData> onLoggedin;

  @override
  _LoginMainPageState createState() {
    return _LoginMainPageState();
  }
}

class _LoginMainPageState extends State<LoginMainPage> {
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('ePro'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Register'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
                padding: Util.outerPadding(context),
                child: LoginPage(onLoggedin: widget.onLoggedin)),
            SingleChildScrollView(
                padding: Util.outerPadding(context),
                child: RegistrationPage(onLoggedin: widget.onLoggedin)),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.onLoggedin}) : super(key: key);
  final ValueChanged<CheckInData> onLoggedin;

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    loadLoginData();
  }

  TextEditingController passwordFieldController = TextEditingController();
  final emailField = TextFormField(
    keyboardType: TextInputType.emailAddress,
    controller: TextEditingController(),
    style: TextStyle(fontSize: 18.0),
    decoration: InputDecoration(
        labelText: 'eMail',
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: 'Enter eMail Id',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
  );

  final rememberMeKey = new GlobalKey<StatefulCheckBoxState>();

  void loadLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    rememberMe = prefs.containsKey('rememberMe') && prefs.getBool('rememberMe');
    if (rememberMe) {
      String email = prefs.getString('email');
      emailField.controller.text = email;
      String password = prefs.getString('password');
      passwordFieldController.text = password;
      rememberMeKey.currentState.setState(() {
        rememberMeKey.currentState.selected = rememberMe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginButon = ButtonWithCircularProgress(
      text: 'Login',
      onPressed: () async {
        var email = emailField.controller.text;
        var password = passwordFieldController.text;
        await login(email, password, rememberMeKey.currentState.selected);
      },
    );

    return Column(
      children: <Widget>[
        SizedBox(
          height: 155.0,
          child: Image.asset('image/check_in.png', fit: BoxFit.contain),
        ),
        SizedBox(height: 20.0),
        emailField,
        SizedBox(height: 20.0),
        PasswordField(
            labelText: 'Password',
            hintText: 'Enter Password',
            editingController: passwordFieldController),
        SizedBox(
          height: 20.0,
        ),
        StatefulCheckBox(
            key: rememberMeKey, text: 'Remember Me', selected: rememberMe),
        SizedBox(
          height: 20.0,
        ),
        loginButon,
      ],
    );
  }

  login(String email, String password, bool rememberMe) async {
    if (email == null || email == '') {
      Util.snackBar(context, 'eMail is required');
      return;
    }
    if (password == null || password == '') {
      Util.snackBar(context, 'password is required');
      return;
    }
    await new Future.delayed(const Duration(seconds: 1));
    var data = {'email': email, 'password': password};
    CheckInData checkInData = CheckInData();
    var rslt = await Util.callApi(context, 'AppsCommon', 'login', data);
    if (rslt.rc != 0) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('rememberMe', rememberMe);
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    } else {
      await prefs.remove('rememberMe');
      await prefs.remove('email');
      await prefs.remove('password');
    }
    var id = rslt.data;
    rslt = await checkInData.init(context, id);
    if (rslt.rc != 0) return;
    //Util.snackBar(context, 'Logged in as $email');
    //await new Future.delayed(const Duration(seconds: 1));
    widget.onLoggedin(checkInData);
  }
}

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key key, this.onLoggedin}) : super(key: key);
  final ValueChanged<CheckInData> onLoggedin;

  @override
  _RegistrationPageState createState() {
    return _RegistrationPageState();
  }
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController passwordFieldController = TextEditingController();
  TextEditingController confirmPasswordFieldController =
      TextEditingController();
  final emailField = TextFormField(
    keyboardType: TextInputType.emailAddress,
    controller: TextEditingController(),
    style: TextStyle(fontSize: 18.0),
    decoration: InputDecoration(
        labelText: 'eMail',
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: 'Enter eMail Id',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
  );

  @override
  Widget build(BuildContext context) {
    final registerButton = ButtonWithCircularProgress(
      text: 'Register',
      onPressed: () async {
        var email = emailField.controller.text;
        var password = passwordFieldController.text;
        var confirmPassword = confirmPasswordFieldController.text;
        await register(email, password, confirmPassword);
      },
    );

    return Column(
      children: <Widget>[
        SizedBox(
          height: 155.0,
          child: Image.asset('image/check_in.png', fit: BoxFit.contain),
        ),
        SizedBox(height: 20.0),
        emailField,
        SizedBox(height: 20.0),
        PasswordField(
            labelText: 'Password',
            hintText: 'Enter Password',
            editingController: passwordFieldController),
        SizedBox(
          height: 20.0,
        ),
        PasswordField(
            labelText: 'Confirm Password',
            hintText: 'Confirm Password',
            editingController: confirmPasswordFieldController),
        SizedBox(
          height: 20.0,
        ),
        registerButton,
        SizedBox(
          height: 15.0,
        ),
      ],
    );
  }

  register(String email, String password, String confirmPassword) async {
    if (email == null || email == '') {
      Util.snackBar(context, 'eMail is required');
      return;
    }
    if (password == null || password == '') {
      Util.snackBar(context, 'password is required');
      return;
    }
    if (confirmPassword == null || confirmPassword == '') {
      Util.snackBar(context, 'Confirm Password is required');
      return;
    }
    if (confirmPassword != password) {
      Util.snackBar(context, 'Password and Confirm Password must match');
      return;
    }

    var data = {'email': email, 'password': password};
    var rslt = await Util.callApi(context, 'AppsCommon', 'registerUser', data);
    if (rslt.rc != 0) return;
    Util.snackBar(context, 'Registration succesful');

    CheckInData checkInData = CheckInData();
    rslt = await Util.callApi(context, 'AppsCommon', 'login', data);
    if (rslt.rc != 0) return;
    var id = rslt.data;
    rslt = await checkInData.init(context, id);
    if (rslt.rc != 0) return;
    widget.onLoggedin(checkInData);
  }
}
