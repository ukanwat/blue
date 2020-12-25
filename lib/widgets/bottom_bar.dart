import 'package:flutter/material.dart';
bottomBar(GlobalKey<ScaffoldState> _scaffoldKey,String text, {Duration duration}){
 _scaffoldKey.currentState.showSnackBar(
                      new SnackBar(duration: duration == null? Duration(seconds: 4):duration, content:
                      Container(
                        height: 45,
                        color: Colors.blue[700],
                        child: new Row(
                          children: <Widget>[
                            new Text(text)
                          ],
                        ),
                      ),
                      ));
  
}