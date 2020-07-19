import 'package:flutter/material.dart';

 circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10,bottom: 2),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Color.fromRGBO(3, 23, 84, 1),
      ),
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
