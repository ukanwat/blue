// Flutter imports:
import 'package:blue/constants/app_colors.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
import 'package:blue/widgets/dialogs/empty_dialog.dart';

class BannerDialog extends StatelessWidget {
  final String title;
  final String content;
  final bool showOk;
  BannerDialog(this.title, this.content, this.showOk);
  @override
  Widget build(BuildContext context) {
    return EmptyDialog(Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!showOk)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    FluentIcons.dismiss_circle_24_filled,
                    color: Colors.grey,
                  ))
            ],
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ),
        SizedBox(
          height: 12,
        ),
        Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5 -
                  MediaQuery.of(context).padding.vertical),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    content,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        if (showOk)
          FlatButton(
            height: 36,
            minWidth: MediaQuery.of(context).size.width * 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.blue,
            onPressed: () {
              Navigator.of(context).pop(); // To close the dialog
            },
            child: Text(
              'Okay',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
      ],
    ));
  }
}
