import 'package:flutter/material.dart';

class ShowDialog extends StatelessWidget {
  final String title, description, leftButtonText,rightButtonText;
final Function leftButtonFunction;
  ShowDialog({
    @required this.title,
    @required this.description,
    @required this.leftButtonText,
   @required this.rightButtonText,
    this.leftButtonFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
      ),      
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
  padding: EdgeInsets.symmetric(
    vertical: 20,
    horizontal: 15
  ),
  decoration: new BoxDecoration(
    color: Colors.white,
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
        title,
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w700,
        ),
      ),
      if(description != "") SizedBox(height: 16.0),
      if(description != "")
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
      SizedBox(height: 24.0), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FlatButton(shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
      ),
              onPressed:leftButtonFunction != null?leftButtonFunction: () {
                Navigator.of(context).pop(); // To close the dialog
              },
              child: Text(leftButtonText,
              ),
            ),
             FlatButton(shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
      ), color: Colors.blue,
              onPressed: () {
                Navigator.of(context).pop(); // To close the dialog
              },
              child: Text(rightButtonText,
              style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      
    ],
  ),
),
    );
  }
}