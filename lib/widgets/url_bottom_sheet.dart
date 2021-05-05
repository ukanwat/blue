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
        snappings: [0.7, 1.0],
        positioning: SnapPositioning.relativeToAvailableSpace,
      ),
      builder: (context, state) {
        return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 10000, minHeight: 500),
            child: WebView(
              initialUrl: 'https://www.youtube.com',
            ));
      },
    );
  });

  print(result); // This is the result.
}
