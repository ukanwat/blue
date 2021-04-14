import 'dart:async';

import 'package:blue/services/auth_service.dart';
import 'package:blue/widgets/email_verify_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return Container(
        color: Theme.of(context).accentColor,
        child: EmailVerifyDialog(AuthService.firebaseAuth.currentUser));
  }
}
