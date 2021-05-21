import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
            leading: Icon(
              FluentIcons.lock_closed_24_filled,
              color: Colors.lightBlueAccent,
              size: 20,
            ),
            title: Text(url),
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
        return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: MyStatelessWidget(url));
      },
    );
  });

  print(result); // This is the result.
}

class MyStatelessWidget extends StatefulWidget {
  final String url;
  MyStatelessWidget(this.url, {Key key}) : super(key: key);

  @override
  _MyStatelessWidgetState createState() => _MyStatelessWidgetState();
}

class _MyStatelessWidgetState extends State<MyStatelessWidget> {
  List<WebViewController> _listController = List();

  // List<double> _heights =
  //     List<double>.generate(htmlStrings.length, (int index) => 20.0);
  String url;
  @override
  void initState() {
    url = widget.url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://' + url;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      child: WebView(
        initialUrl: url,
        // onPageFinished: (some) async {
        //   double height = double.parse(await _listController[index]
        //       .evaluateJavascript(
        //           "document.documentElement.scrollHeight;"));
        //   setState(() {
        //     _heights[index] = height;
        //   });
        // },
        javascriptMode: JavascriptMode.unrestricted,

        onWebViewCreated: (controller) async {
          _listController.add(controller);
        },
      ),
    );
  }
}
