import 'dart:collection';
import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

void showUrlBottomSheet(BuildContext context, String url) async {
  url = url.toLowerCase().replaceAll(new RegExp(r"\s+"), "");
  if (!url.startsWith('https://') && !url.startsWith('http://')) {
    url = 'https://' + url;
  }
  Get.to(() => CustomWebView(url),
      transition: Transition.downToUp); // This is the result.
}

class CustomWebView extends StatefulWidget {
  final String url;
  CustomWebView(this.url);
  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  bool t = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: ListTile(
          dense: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(
              FluentIcons.lock_closed_24_filled,
              color: Colors.greenAccent,
              size: 20,
            ),
          ),
          title: Text(
            widget.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: IconButton(
            icon: Icon(FluentIcons.chevron_double_down_16_filled),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: WebViewPlus(
          onWebViewCreated: (controller) {
            controller.loadUrl(widget.url);
          },
          // onProgress: (url) {
          //   _controller.getHeight().then((double height) {
          //     t = true;
          //     if (height > 1000)
          //       setState(() {
          //         _height = height + 400;
          //       });
          //   });
          // },
          // onPageFinished: (url) {
          //   _controller.getHeight().then((double height) {
          //     t = true;

          //     setState(() {
          //       _height = height;
          //     });
          //   });
          // },

          javascriptMode: JavascriptMode.unrestricted),
    );
  }
}
