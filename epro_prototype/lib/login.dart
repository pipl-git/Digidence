import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'epro_widget.dart';
import 'util.dart';
import 'checkin.dart';

class LoginPage extends StatefulWidget {
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
    final loginButton = Builder(builder: (context) {
      return ButtonWithCircularProgress(
        text: 'Login',
        onPressed: () async {
          var email = emailField.controller.text;
          var password = passwordFieldController.text;
          await login(context, email, password, rememberMeKey.currentState.selected);
        },
      );
    });

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Login'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.person_add),
                tooltip: 'Register new user',
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
                    return RegistrationPage();
                  }));
                }),
          ],
        ),
        body: SingleChildScrollView(
            padding: Util.outerPadding(context),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image.asset('image/check_in.png', fit: BoxFit.contain),
                ),
                SizedBox(height: 25.0),
                emailField,
                SizedBox(height: 25.0),
                PasswordField(
                    labelText: 'Password', hintText: 'Enter Password', editingController: passwordFieldController),
                SizedBox(
                  height: 25.0,
                ),
                StatefulCheckBox(key: rememberMeKey, text: 'Remember Me', selected: rememberMe),
                SizedBox(
                  height: 25.0,
                ),
                loginButton,
              ],
            )));
  }

  login(BuildContext context, String email, String password, bool rememberMe) async {
    if (email == null || email == '') {
      Util.snackBar(context, 'eMail is required');
      return;
    }
    if (password == null || password == '') {
      Util.snackBar(context, 'password is required');
      return;
    }
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
    await checkInData.init(context, id);
  }
}

class RegistrationPage extends StatelessWidget {
  final TextEditingController passwordFieldController = TextEditingController();
  final TextEditingController confirmPasswordFieldController = TextEditingController();
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
    final registerButton = Builder(builder: (context) {
      return ButtonWithCircularProgress(
        text: 'Register',
        onPressed: () async {
          var email = emailField.controller.text;
          var password = passwordFieldController.text;
          var confirmPassword = confirmPasswordFieldController.text;
          await register(context, email, password, confirmPassword);
        },
      );
    });

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Register new user'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.person),
                tooltip: 'Login',
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
                    return LoginPage();
                  }));
                }),
          ],
        ),
        body: SingleChildScrollView(
            padding: Util.outerPadding(context),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image.asset('image/check_in.png', fit: BoxFit.contain),
                ),
                SizedBox(height: 20.0),
                emailField,
                SizedBox(height: 20.0),
                PasswordField(
                    labelText: 'Password', hintText: 'Enter Password', editingController: passwordFieldController),
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
            )));
  }

  register(BuildContext context, String email, String password, String confirmPassword) async {
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
    await checkInData.init(context, id);
  }
}
