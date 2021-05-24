// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:blue/widgets/url_bottom_sheet.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/widgets/settings_widgets.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  static const routeName = 'privacy-policy';
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Privacy Policy'),
      body: Container(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.vertical,
        child: CustomWebView(
          'https://www.stark.social/privacy-policy',
        ),
      ),
    );
  }
}
