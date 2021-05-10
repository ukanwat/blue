// Flutter imports:
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';

circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
    child: CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1ee682)),
    ),
//     child:NutsActivityIndicator(
//     radius: 20,endRatio: 0.9,relativeWidth: 0.6,
//     tickCount: 16,
//     startRatio: 0.55,
// ),
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Color.fromRGBO(3, 23, 84, 1),
      ),
    ),
  );
}

ArsProgressDialog progressOverlay({BuildContext context}) {
  return ArsProgressDialog(context,
      blur: 2,
      loadingWidget: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                color: context == null
                    ? Colors.grey[900]
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20)),
            height: 80,
            width: 80,
          ),
          circularProgress()
        ],
      ),
      backgroundColor: Color(0x33000000),
      animationDuration: Duration(milliseconds: 500));
}

snackbar(String text, BuildContext context, {Duration duration, Color color}) {
  showFlash(
      context: context,
      duration: Duration(seconds: 3),
      builder: (_, controller) {
        return Flash(
          controller: controller,
          backgroundColor: color ?? Theme.of(context).cardColor,
          position: FlashPosition.bottom,
          style: FlashStyle.grounded,
          child: FlashBar(
            message: Text(text,
                style: TextStyle(color: Theme.of(context).iconTheme.color)),
          ),
        );
      });
}
