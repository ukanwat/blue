import 'package:blue/providers/provider_widget.dart';
import 'package:blue/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignInViewScreen extends StatelessWidget {
  static const routeName = 'sign-in-view';
  @override
  Widget build(BuildContext context) {

 double scale = MediaQuery.of(context).size.width/411.42857142857144;
   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light
        ,            //TODO
  statusBarBrightness: Brightness.light
 ));
    return Scaffold(
       resizeToAvoidBottomInset: false,
        body: Column(
            children: <Widget>[
             
              Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                   gradient: RadialGradient(
                      colors: [Color.fromRGBO(0, 51, 177, 1),Color.fromRGBO(0, 32, 112, 1)],
                     center: Alignment(-1,0.7),
                  radius: 0.8

                   )
                    ),
                    height: MediaQuery.of(context).size.height * 0.60,
                  ),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: <Widget>[
                       Padding(
                         padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                         child: IconButton(
                onPressed: null,
                icon: Icon(Icons.clear,
                color: Colors.white,
                ),
              ),
                       ),

                       Container(
                         padding: EdgeInsets.only(
                           top:50
                         ),
                         width: double.infinity,
                         child: Center(child: Text('Scrible',style: TextStyle(fontFamily: 'Diskopia',
                         fontSize: 60*scale,
                         color: Colors.white
                         ),
                         ),),)
                     ],
                   ),
                ],
              ),
              Expanded(child: Container()),
              InkWell(
                onTap: ()async {
                  final _auth = Provider.of(context).auth;
                   await _auth.signInWithGoogle(context);
                   
                },
                              child: Container(
                  width: double.infinity,
                  height: 48,
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: <Widget>[
                      Container(
                          height: 48,
                          child: Image.asset(
                              'assets/icons/google_sign_in_button.png')),
                      Container(
                        width: MediaQuery.of(context).size.width - 128,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Expanded(child: Container()),
              Text('OR WITH EMAIL'),
              Expanded(child: Container()),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                onTap: () {
                  
                  Navigator.of(context).pushNamed(SignInScreen.signInRouteName);
                },
                              child: Container(
                        height: 48,
                        width: MediaQuery.of(context).size.width / 2 - 47,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),),
                   SizedBox(
                        width: 14,
                      ),
                      InkWell(onTap: () {
                         Navigator.of(context).pushNamed(SignInScreen.signUpRouteName);
                      },
                                            child: Container(
                          height: 48,
                          width: MediaQuery.of(context).size.width / 2 - 47,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              Expanded(child: Container()),
            ],
          ),
        );
  }
}