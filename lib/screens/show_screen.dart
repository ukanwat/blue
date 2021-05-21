import 'dart:async';

import 'package:blue/services/auth_service.dart';
import 'package:blue/widgets/email_verify_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class ShowScreen extends StatefulWidget {
  static const routeName = 'show';
  @override
  _ShowScreenState createState() => _ShowScreenState();
}

class _ShowScreenState extends State<ShowScreen> {
  StreamSubscription l;
  @override
  void initState() {
    checkVerification();
    super.initState();
  }

  checkVerification() async {
    bool userVerified = false;
    var c = FirebaseAuth.instance.userChanges();
    l = c.listen((user) {
      user.reload();
      if (user.emailVerified) {
        print('  userVerified =   ${user.emailVerified}');
        userVerified = true;
        c = null;
      }
    });

    while (!userVerified) {
      await Future.delayed(Duration(seconds: 1));
      print('  userVerified =   $userVerified');
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    l.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
              color: Color.fromRGBO(240, 240, 240, 1),
              child: EmailVerifyDialog(AuthService.firebaseAuth.currentUser)),
        ),
        Material(
          child: Container(
            color: Color.fromRGBO(240, 240, 240, 1),
            padding: const EdgeInsets.only(bottom: 30),
            child: Center(
                child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FluentIcons.chevron_left_24_filled,
                    color: Colors.blue,
                  ),
                  Text(
                    'Go Back',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            )),
          ),
        ),
      ],
    );
  }
}
