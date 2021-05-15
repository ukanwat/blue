// Flutter imports:

import 'package:auth_buttons/auth_buttons.dart';
import 'package:blue/main.dart';
import 'package:blue/providers/verify_email.dart';
import 'package:blue/screens/email_sign_in_screen.dart';
import 'package:blue/screens/post_screen.dart';
import 'package:blue/screens/set_name_screen.dart';
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/boxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Project imports:
import 'package:blue/providers/provider_widget.dart';
import 'package:blue/screens/sign_in_screen.dart';
import 'package:blue/screens/tabs_screen.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
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
                    height: 50,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 50),
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Stark',
                        style: TextStyle(
                            fontFamily: 'Techna Sans Regular',
                            fontSize: 90 * scale,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: Center(
              child: Text(
                'Fun & Interesting',
                style: TextStyle(
                    fontFamily: 'Techna Sans Regular',
                    fontSize: 30 * scale,
                    color: Colors.white.withOpacity(0.8)),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            width: double.infinity,
            child: Center(
              child: Text('Explore Now',
                  style: TextStyle(
                      fontFamily: 'Techna Sans Regular',
                      fontSize: 35 * scale,
                      color: Theme.of(context).accentColor)),
            ),
          ),
          Expanded(child: Container()),
          SizedBox(
            height: 10,
          ),

          // InkWell(
          //   onTap: () async {
          //     final _auth = Provider.of(context).auth;
          //     bool exists = await _auth.signInWithGoogle(context);
          //     var result;
          //     if (!exists) {
          //       result = await navigatorKey.currentState.pushNamed(
          //           SetNameScreen.routeName,
          //           arguments: {"provider": "google"});
          //     }
          //     await _auth.signInWithGoogleMore(context, exists, result);

          //     // Navigator.pushNamed(
          //     //     context, TabsScreen.routeName); //TODO replacement?
          //   },
          //   child: Container(
          //     width: double.infinity,
          //     height: 48,
          //     margin: EdgeInsets.symmetric(horizontal: 40),
          //     padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          //     child: Row(
          //       children: <Widget>[
          //         CircleAvatar(
          //           backgroundImage:
          //               AssetImage('assets/icons/google_sign_in_button.png'),
          //           radius: 24,
          //         ),
          //         Container(
          //           width: MediaQuery.of(context).size.width - 140,
          //           child: Center(
          //             child: Text(
          //               'Sign in with Google',
          //               style: TextStyle(
          //                   color: Colors.white,
          //                   fontSize: 18,
          //                   fontWeight: FontWeight.w500),
          //             ),
          //           ),
          //         )
          //       ],
          //     ),
          //     decoration: BoxDecoration(
          //       color: Color.fromRGBO(66, 133, 244, 1),
          //       borderRadius: BorderRadius.circular(40),
          //     ),
          //   ),
          // ),
          // 
          Container(
            height: 45,
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
            height: 20,
          ),
          Container(
            height: 45,
            child: EmailAuthButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(EmailSignInScreen.routeName);
                },
                darkMode: true,
                text: 'Sign in with Email  ',
                style: AuthButtonStyle(
                  iconType: AuthIconType.secondary,
                )),
          ),
          SizedBox(
            height: 70,
          )
          // Padding(
          //   padding: const EdgeInsets.only(top: 20),
          //   child: Text(
          //     'OR WITH EMAIL',
          //     style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          //   ),
          // ),

          // Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          //     child: InkWell(
          //       onTap: () {
          //         Navigator.of(context).pushNamed(EmailSignInScreen.routeName);
          //       },
          //       child: Container(
          //         height: 48,
          //         width: double.infinity,
          //         decoration: BoxDecoration(
          //           color: Theme.of(context).cardColor,
          //           borderRadius: BorderRadius.circular(80),
          //         ),
          //         child: Center(
          //           child: Text(
          //             'Email Sign in',
          //             style:
          //                 TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          //           ),
          //         ),
          //       ),
          //     )),
        ],
      ),
    );
  }
}
