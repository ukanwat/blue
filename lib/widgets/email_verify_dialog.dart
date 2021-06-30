// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:blue/widgets/empty_dialog.dart';

class EmailVerifyDialog extends StatelessWidget {
  final User _user;
  EmailVerifyDialog(this._user);
  @override
  Widget build(BuildContext context) {
    return EmptyDialog(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 30),
            child: Icon(
              Icons.email_rounded,
              size: 40,
              color: Colors.blue,
            ),
          ),
          Text(
            'We just sent you an email\nClick on verify link to Sign up',
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black),
          ),
          SizedBox(
            height: 30,
          ),
          ArgonTimerButton(
            initialTimer: 30, // Optional
            height: 50,
            width: MediaQuery.of(context).size.width * 0.35,
            minWidth: 50,
            color: Colors.white,
            borderRadius: 10.0,
            borderSide:
                BorderSide(color: Theme.of(context).accentColor, width: 3),
            child: Text(
              "Resend Link",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            loader: (timeLeft) {
              return Text(
                "$timeLeft",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              );
            },
            onTap: (startTimer, btnState) {
              if (btnState == ButtonState.Idle) {
                startTimer(20);

                _user.sendEmailVerification();
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
      color: Colors.white,
    );
  }
}
