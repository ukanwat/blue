// Flutter imports:

// Dart imports:
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
        extendBodyBehindAppBar: true,
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: CarouselSlider(
                        options: CarouselOptions(
                            autoPlay: true,
                            enlargeCenterPage: false,
                            height: MediaQuery.of(context).size.height * 0.55,
                            initialPage: 0,
                            viewportFraction: 1,
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 200),
                            autoPlayInterval: Duration(seconds: 4),
                            enableInfiniteScroll: false),

                        // Carousel(
                        //                             dotVerticalPadding: 0,
                        //                             dotSize: 6,
                        //                             dotIncreaseSize: 1.5,
                        //                             dotIncreasedColor: Colors.white,
                        //                             dotColor: Colors.grey.withOpacity(0.5),
                        //                             showIndicator: true,
                        //                             dotPosition: DotPosition.bottomCenter,
                        //                             dotSpacing: 15,
                        //                             boxFit: BoxFit.fitWidth,
                        //                             dotBgColor: Colors.transparent,
                        //                             autoplay: false,
                        //                             overlayShadow: false,
                        //                             moveIndicatorFromBottom: 20,
                        items: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              'assets/gifs/1.gif',
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              'assets/gifs/2.gif',
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              'assets/gifs/3.gif',
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              'assets/gifs/4.gif',
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              'assets/gifs/5.gif',
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ]),
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.55,
                    ),
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
                                height: 60,
                                child: Image.asset('assets/logo.png'))),
                        Expanded(
                          child: Center(
                            child: Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: scale * 40),
                              child: Center(
                                child: DefaultTextStyle(
                                  style: const TextStyle(
                                    fontSize: 32.0,
                                    fontFamily: 'Techna Sans Regular',
                                  ),
                                  child: AnimatedTextKit(
                                    repeatForever: true,
                                    animatedTexts: [
                                      FadeAnimatedText(
                                          'Explore New & Interesting Posts',
                                          duration: Duration(seconds: 4)),
                                      FadeAnimatedText(
                                          'Discover News, Entertainment, Sports, Gaming, Art, Tech, etc.',
                                          duration: Duration(seconds: 4)),
                                      FadeAnimatedText('Chat with Friends',
                                          duration: Duration(seconds: 4)),
                                      FadeAnimatedText('Track your Activity',
                                          duration: Duration(seconds: 4)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Container(
                            child: Text(
                              'Welcome to Stark',
                              style: TextStyle(
                                fontFamily: 'Techna Sans Regular',
                                fontSize: 24 * scale,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            child: Text(
                              'Sign In to Continue.',
                              style: TextStyle(
                                fontFamily: 'Techna Sans Regular',
                                fontSize: 24 * scale,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
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
                        SignInButton(
                          Buttons.Google,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          onPressed: () {
                            googleSignIn(context);
                          },
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
                      ],
                    ),
                    Column(
                      children: [
                        Text('By Creating an account, you agree to Stark',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                                    color: Colors.grey,
                                    fontSize: 11,
                                    decoration: TextDecoration.underline,
                                  )),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text('and',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
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
                                    color: Colors.grey,
                                    fontSize: 11,
                                    decoration: TextDecoration.underline,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
