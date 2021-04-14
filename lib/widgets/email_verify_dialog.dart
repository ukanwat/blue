import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:blue/widgets/empty_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerifyDialog extends StatelessWidget {
  final User _user;
  EmailVerifyDialog(this._user);
  @override
  Widget build(BuildContext context) {
    return EmptyDialog(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: Text(
                'Go back',
                style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 18,
                    color: Theme.of(context).iconTheme.color.withOpacity(0.6)),
              ),
              onPressed: () {},
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: Icon(
            Icons.email_rounded,
            size: 40,
            color: Colors.blue,
          ),
        ),
        Text(
          'We just sent you an email\nClick on verify link to Sign up',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        SizedBox(
          height: 30,
        ),
        ArgonTimerButton(
          initialTimer: 30, // Optional
          height: 50,
          width: MediaQuery.of(context).size.width * 0.35,
          minWidth: 50,
          color: Colors.transparent,
          borderRadius: 5.0,
          borderSide:
              BorderSide(color: Theme.of(context).accentColor, width: 3),
          child: Text(
            "Resend Link",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).iconTheme.color),
          ),
          loader: (timeLeft) {
            return Text(
              "$timeLeft",
              style: TextStyle(
                  color: Theme.of(context).iconTheme.color,
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
    ));
  }
}
