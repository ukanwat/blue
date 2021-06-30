// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/widgets/progress.dart';

class VerifyEmailScreen extends StatelessWidget {
  static String routeName = 'verify-email';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          circularProgress(),
          Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  'We just sent you an email\nClick on verification link to Sign up',
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                )),
          ),
        ],
      ),
    );
  }
}
