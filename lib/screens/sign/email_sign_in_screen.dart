// Flutter imports:
import 'package:blue/constants/app_colors.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_login/flutter_login.dart';

// Project imports:
import 'package:blue/screens/sign_in_view_screen.dart';
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/dialogs/empty_dialog.dart';
import 'package:blue/widgets/progress.dart';
import '../../main.dart';
import 'set_name_screen.dart';

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
    var uid = await AuthService()
        .createUserWithEmailAndPassword(data.name, data.password, context);
    if (uid == null) {
      return 'error';
    }
    signupData = data;

    return null;
  }

  Future<String> loginUser(LoginData data) async {
    var a = await AuthService().loginUser(data, context);
    if (a == null) {
      return 'Something went Wrong!';
    }
    return null;
  }

  Future<String> _recoverPassword(String name) async {
    await AuthService().sendPasswordResetEmail(name);
    return null;
  }

  @override
  void initState() {
    // if (ldata != null) {
    //   ldata = null;
    //   loginUser(widget.ld);
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromRGBO(240, 240, 240, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Theme(
            data: ThemeData(),
            child: FlutterLogin(
              key: UniqueKey(),
              title: 'Welcome',
              logo: 'assets/logo.png',
              onLogin: loginUser,
              onSignup: signupUser,
              onSubmitAnimationCompleted: () async {
                if (signupData != null) {
                  userSignedIn = false;

                  AuthService().signOut(context);

                  var a = await AuthService().loginUser(signupData, context);
                  if (a == null) {
                    return;
                  }
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
                  titleStyle: TextStyle(
                      fontFamily: 'Techna Sans Regular',
                      color: Colors.black,
                      fontSize: 30),
                  primaryColor: Color.fromRGBO(240, 240, 240, 1),
                  accentColor: Colors.grey,
                  inputTheme: InputDecorationTheme(
                      fillColor: Colors.grey[300],
                      prefixStyle: TextStyle(
                          color: Colors.grey,
                          decorationColor: Colors.grey,
                          backgroundColor: Colors.grey),
                      suffixStyle: TextStyle(
                          color: Colors.grey, decorationColor: Colors.grey),
                      focusColor: Colors.grey,
                      hoverColor: Colors.grey,
                      labelStyle: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                      filled: true,
                      border: InputBorder.none,
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(50)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(50))),
                  buttonStyle: TextStyle(
                      color: Colors.white,
                      decorationStyle: TextDecorationStyle.solid,
                      decorationColor: Colors.grey,
                      fontStyle: FontStyle.normal,
                      backgroundColor: Colors.grey.withOpacity(0.5)),
                  buttonTheme: LoginButtonTheme(
                    backgroundColor: Theme.of(context).accentColor,
                    highlightColor: Theme.of(context).accentColor,
                  ),
                  textFieldStyle: TextStyle(color: Colors.black),
                  bodyStyle: TextStyle(
                    decorationColor: Colors.grey,
                    color: Colors.black,
                    fontStyle: FontStyle.normal,
                  ),
                  cardTheme: CardTheme(
                    color: Colors.white,
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 0, top: 500),
            child: Center(
                child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FluentIcons.chevron_left_24_filled,
                    color: AppColors.blue,
                  ),
                  Text(
                    'Back',
                    style: TextStyle(
                        fontSize: 18,
                        color: AppColors.blue,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}
