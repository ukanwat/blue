import 'dart:collection';
import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

void showUrlBottomSheet(BuildContext context, String url) async {
  final result = await showSlidingBottomSheet(context, builder: (context) {
    return SlidingSheetDialog(
        elevation: 8,
        cornerRadius: 16,
        snapSpec: const SnapSpec(
          snap: true,
          snappings: [0.95],
          positioning: SnapPositioning.relativeToAvailableSpace,
        ),
        headerBuilder: (context, SheetState ss) {
          return Material(
            child: ListTile(
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
                url,
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
          );
        },
        builder: (context, state) {
          return Material(child: CustomWebView(url));
        });
  });

  print(result); // This is the result.
}

class CustomWebView extends StatefulWidget {
  final String url;
  CustomWebView(this.url);
  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  WebViewPlusController _controller;
  double _height = 100000;
  bool t = false;

  load() async {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      if (_controller != null) {
        var h = await _controller.getHeight();

        // print(h);
      }
    }
  }

  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: WebViewPlus(
        onWebViewCreated: (controller) {
          this._controller = controller;
          controller.loadUrl(widget.url);
        },
        onPageFinished: (url) {
          _controller.getHeight().then((double height) {
            t = true;
            print(height);
            setState(() {
              _height = height;
            });
          });
        },
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
