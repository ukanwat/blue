// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:blue/widgets/url_bottom_sheet.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Terms Of Use'),
      body: Container(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.vertical,
          child: CustomWebView('https://www.stark.social/terms')),
    );
  }
}
