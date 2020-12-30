// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';

 circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 20,bottom: 20,left: 20,right: 20),
    child:NutsActivityIndicator(
    radius: 20,endRatio: 0.9,relativeWidth: 0.6,
    tickCount: 16,
    startRatio: 0.55,
),
 
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
