// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:blue/widgets/settings_widgets.dart';

class TermsOfServiceScreen extends StatefulWidget {
  static const routeName = 'terms-of-service';
  @override
  _TermsOfServiceScreenState createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Terms Of Use'),
      body: WebView(
        initialUrl: 'https://www.scrible.app/terms/',
          onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
    );
  }
}
