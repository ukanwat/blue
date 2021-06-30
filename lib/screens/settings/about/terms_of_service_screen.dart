// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

// Project imports:
import 'package:blue/widgets/settings_widgets.dart';
import 'package:blue/widgets/url_bottom_sheet.dart';

class TermsOfServiceScreen extends StatefulWidget {
  static const routeName = 'terms-of-service';
  @override
  _TermsOfServiceScreenState createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: settingsHeader(context, 'Terms Of Use'),
        body: WebViewPlus(
          onWebViewCreated: (controller) {
            controller.loadUrl('https://www.stark.social/terms');
          },
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
