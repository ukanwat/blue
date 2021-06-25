// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:blue/widgets/url_bottom_sheet.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/widgets/settings_widgets.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

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
        body: WebViewPlus(
          onWebViewCreated: (controller) {
            controller.loadUrl('https://www.stark.social/privacy-policy');
          },
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
