// Flutter imports:

// Dart imports:
import 'package:universal_platform/universal_platform.dart';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/main.dart';
import 'package:blue/state_management/provider_widget.dart';
import 'package:blue/state_management/verify_email.dart';
import 'package:blue/screens/sign/email_sign_in_screen.dart';
import 'package:blue/screens/post/post_screen.dart';
import 'package:blue/screens/sign/set_name_screen.dart';
import 'package:blue/screens/tabs_screen.dart';
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/functions.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
    await _auth.signInContinue(context, exists, result, apple: true);
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 30),
                  ),
                  Center(
                      child: Container(
                          height: 100, child: Image.asset('assets/logo.png'))),
                  Container(
                    padding: EdgeInsets.only(left: 0),
                    width: double.maxFinite,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              padding: EdgeInsets.only(top: 50),
                              child: Text(
                                'Welcome To',
                                style: TextStyle(
                                    fontFamily: 'Techna Sans Regular',
                                    fontSize: 30 * scale,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              child: Text(
                                'Stark',
                                style: TextStyle(
                                  fontFamily: 'Techna Sans Regular',
                                  fontSize: 60 * scale,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 0,
            ),
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
                    if (UniversalPlatform.isIOS)
                      SignInButton(
                        Buttons.Apple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        onPressed: () {
                          appleSignIn(context);
                        },
                      ),
                    SignInButton(
                      Buttons.Facebook,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onPressed: () {
                        facebookSignIn(context);
                      },
                    ),
                    if (UniversalPlatform.isWeb)
                      SizedBox(
                        height: 10,
                      ),
                    SignInButton(
                      Buttons.Google,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onPressed: () {
                        googleSignIn(context);
                      },
                    ),
                    if (UniversalPlatform.isWeb)
                      SizedBox(
                        height: 10,
                      ),
                    SignInButton(
                      Buttons.Email,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(EmailSignInScreen.routeName);
                      },
                    ),
                    SizedBox(
                      height: 10,
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
