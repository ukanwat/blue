// Flutter imports:

import 'dart:io';

import 'package:auth_buttons/auth_buttons.dart';
import 'package:blue/main.dart';
import 'package:blue/providers/verify_email.dart';
import 'package:blue/screens/email_sign_in_screen.dart';
import 'package:blue/screens/post_screen.dart';
import 'package:blue/screens/set_name_screen.dart';
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Project imports:
import 'package:blue/providers/provider_widget.dart';
import 'package:blue/screens/sign_in_screen.dart';
import 'package:blue/screens/tabs_screen.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:blue/main.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

bool autoLogin = false;

class SignInViewScreen extends StatefulWidget {
  static const routeName = 'sign-in-view';

  @override
  _SignInViewScreenState createState() => _SignInViewScreenState();
}

class _SignInViewScreenState extends State<SignInViewScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  googleSignIn(BuildContext context) async {
    final _auth = Provider.of(context).auth;
    bool exists = await _auth.signInWithGoogle(context);
    var result;
    if (!exists) {
      result = await navigatorKey.currentState.pushNamed(
          SetNameScreen.routeName,
          arguments: {"provider": "google"});
    }
    await _auth.signInContinue(context, exists, result);
  }

  appleSignIn(BuildContext context) async {
    final _auth = Provider.of(context).auth;
    bool exists = await _auth.signInWithApple();
    var result;
    if (!exists) {
      result = await navigatorKey.currentState
          .pushNamed(SetNameScreen.routeName, arguments: {"provider": "apple"});
    }
    await _auth.signInContinue(context, exists, result);
  }

  facebookSignIn(BuildContext context) async {
    final _auth = Provider.of(context).auth;
    bool exists = await _auth.signInWithFacebook(context);
    var result;
    if (!exists) {
      result = await navigatorKey.currentState.pushNamed(
          SetNameScreen.routeName,
          arguments: {"provider": "facebook"});
    }
    await _auth.signInContinue(context, exists, result);
  }

  @override
  Widget build(BuildContext context) {
    double scale = MediaQuery.of(context).size.width / 411.42857142857144;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, //TODO
        statusBarBrightness: Brightness.light));
    return WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Center(
                        child: Container(
                            height: 120,
                            child: Image.asset('assets/logo.png'))),
                    Container(
                      padding: EdgeInsets.only(top: 50),
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Welcome To',
                          style: TextStyle(
                              fontFamily: 'Techna Sans Regular',
                              fontSize: 30 * scale,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: double.infinity,
              child: Center(
                child: Text(
                  'Stark',
                  style: TextStyle(
                      fontFamily: 'Techna Sans Regular',
                      fontSize: 90 * scale,
                      color: Colors.black),
                ),
              ),
            ),
            SizedBox(
              height: 0,
            ),
            Container(
              width: double.infinity,
              child: Center(
                child: Text('Explore Now',
                    style: TextStyle(
                        fontFamily: 'Techna Sans Regular',
                        fontSize: 35 * scale,
                        color: Colors.blue)),
              ),
            ),
            Expanded(child: Container()),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 290,
                  decoration: new BoxDecoration(
                    gradient: FlutterGradients.aquaGuidance(),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.elliptical(
                            MediaQuery.of(context).size.width, 120.0)),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    if (false)
                      Container(
                        height: 45,
                        width: 285,
                        child: AppleAuthButton(
                            onPressed: () {
                              appleSignIn(context);
                            },
                            darkMode: true,
                            style: AuthButtonStyle(
                              iconType: AuthIconType.outlined,
                            )),
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 45,
                      width: 285,
                      child: FacebookAuthButton(
                          onPressed: () {
                            facebookSignIn(context);
                          },
                          darkMode: true,
                          style: AuthButtonStyle(
                            iconType: AuthIconType.outlined,
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 45,
                      width: 285,
                      child: GoogleAuthButton(
                          onPressed: () {
                            googleSignIn(context);
                          },
                          darkMode: true,
                          style: AuthButtonStyle(
                            iconType: AuthIconType.secondary,
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 45,
                      width: 285,
                      child: EmailAuthButton(
                          darkMode: true,
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(EmailSignInScreen.routeName);
                          },
                          text: 'Sign in with Email   ',
                          style: AuthButtonStyle(
                            iconType: AuthIconType.secondary,
                          )),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text('By Creating an account, you agree to Stark',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Functions().launchURL(
                                'https://www.stark.social/terms', context);
                          },
                          child: Text('Terms of Service',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                decoration: TextDecoration.underline,
                              )),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text('and',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11)),
                        SizedBox(
                          width: 4,
                        ),
                        GestureDetector(
                          onTap: () {
                            Functions().launchURL(
                                'https://www.stark.social/privacy-policy',
                                context);
                          },
                          child: Text('Privacy Policy',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                decoration: TextDecoration.underline,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
