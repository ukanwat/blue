// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// Project imports:
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/progress.dart';

class ReportDialog extends StatefulWidget {
  final int postId;
  final String postTitle;
  ReportDialog(this.postId, this.postTitle);

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: new BoxDecoration(
          color: Theme.of(context).canvasColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Text(
              "Report an issue",
              style: TextStyle(
                color: Theme.of(context).iconTheme.color.withOpacity(0.8),
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Text(
                  widget.postTitle,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            InkWell(
              onTap: () async {
                snackbar('post reported', Get.context);
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).cardColor),
                height: 40,
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 2),
                child: Center(
                  child: Text(
                    "It's Abusive",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).cardColor),
                height: 40,
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 2),
                child: Center(
                  child: Text(
                    "It's Spam",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                snackbar('post reported', Get.context);
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).cardColor),
                height: 40,
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 2),
                child: Center(
                  child: Text(
                    "It's Inappropriate",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            FlatButton(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () {
                snackbar('post reported', Get.context);
                Navigator.of(context).pop(); // To close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
