import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:blue/screens/sign_in_view_screen.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/empty_dialog.dart';
import 'package:blue/widgets/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:blue/services/auth_service.dart';
import '../main.dart';
import './set_name_screen.dart';

class EmailSignInScreen extends StatefulWidget {
  static const routeName = 'emai-sign-in';
  final LoginData ld;
  EmailSignInScreen({this.ld, Key key}) : super(key: UniqueKey());
  @override
  _EmailSignInScreenState createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  bool hasuraUserExists = false;
  bool error = false;
  String email;
  String id;
  LoginData signupData;
  Future<String> signupUser(LoginData data) async {
    print('Email: ${data.name}, Password: ${data.password}');

    await AuthService()
        .createUserWithEmailAndPassword(data.name, data.password);
    signupData = data;

    return null;
  }

  Future<String> loginUser(LoginData data) async {
    await AuthService().loginUser(data, context);
    return null;
  }

  Future<String> _recoverPassword(String name) async {
    await AuthService().sendPasswordResetEmail(name);
    return null;
  }

  @override
  void initState() {
    // if (ldata != null) {
    //   print('ld : ${ldata.name}');
    //   ldata = null;
    //   loginUser(widget.ld);
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      key: UniqueKey(),
      title: 'Stark',
      logo: 'assets/images/stark-bnb-icon-wa.png',
      onLogin: loginUser,
      onSignup: signupUser,
      onSubmitAnimationCompleted: () async {
        if (signupData != null) {
          userSignedIn = false;

          AuthService().signOut(context);

          await AuthService().loginUser(signupData, context);
        }

        // if (error) {
        //   return;
        // } //TODO
        // if (!hasuraUserExists) {
        //   Navigator.pushNamed(context, SetNameScreen.routeName,
        //       arguments: {'provider': 'email', 'email': email});
        // } else {
        //   userSignedIn = true;
        // }
      },
      messages: LoginMessages(),
      onRecoverPassword: _recoverPassword,
      theme: LoginTheme(
          primaryColor: Theme.of(context).accentColor,
          bodyStyle: TextStyle(color: Colors.black),
          cardTheme: CardTheme(color: Colors.white)),
    );
  }
}
