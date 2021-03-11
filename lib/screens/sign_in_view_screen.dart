// Flutter imports:
import 'package:blue/main.dart';
import 'package:blue/screens/email_sign_in_screen.dart';
import 'package:blue/services/boxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:blue/providers/provider_widget.dart';
import 'package:blue/screens/sign_in_screen.dart';
import 'package:blue/screens/tabs_screen.dart';

class SignInViewScreen extends StatelessWidget {
  static const routeName = 'sign-in-view';
  @override
  Widget build(BuildContext context) {
    double scale = MediaQuery.of(context).size.width / 411.42857142857144;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, //TODO
        statusBarBrightness: Brightness.light));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                child: Image.asset('assets/images/sign_in_image.png',fit: BoxFit.cover,),
                height: MediaQuery.of(context).size.height * 0.60,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
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
                  )
                ],
              ),
            ],
          ),
          Expanded(child: Container()),
          InkWell(
            onTap: () async {
              final _auth = Provider.of(context).auth;
             await _auth.signInWithGoogle(context);
              Navigator.pushNamed(context, TabsScreen.routeName);//TODO replacement?
            },
            child: Container(
              width: double.infinity,
              height: 48,
              margin: EdgeInsets.symmetric(horizontal: 40),
              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(backgroundImage:  AssetImage('assets/icons/google_sign_in_button.png'),
                    radius: 24,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Center(
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(66, 133, 244, 1),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text('OR WITH EMAIL',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15),),
          ),
         
                 Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 15),
                  child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(EmailSignInScreen.routeName);
                  },
                  child: Container(
                    height: 48,
                    width:double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(80),
                    ),
                    child: Center(
                      child: Text(
                        'Email Sign in',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                )),
                // SizedBox(
                //   width: 14,
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 0),
                //   child: InkWell(
                //     onTap: () {
                //       Navigator.of(context)
                //           .pushNamed(SignInScreen.signUpRouteName);
                //     },
                //     child: Container(
                //       height: 48,
                //       width: double.infinity,
                //       decoration: BoxDecoration(
                //         color: Theme.of(context).cardColor,
                //         borderRadius: BorderRadius.circular(80),
                //       ),
                //       child: Center(
                //         child: Text(
                //           'Sign up',
                //           style: TextStyle(
                //               fontSize: 18, fontWeight: FontWeight.w500),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
             
          
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
