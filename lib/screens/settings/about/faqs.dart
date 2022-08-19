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

class FAQScreen extends StatefulWidget {
  static const routeName = 'faq';
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: settingsHeader(context, 'FAQ'),
        body: WebViewPlus(
          onWebViewCreated: (controller) {
            controller.loadUrl('https://www.stark.social/faq');
          },
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
