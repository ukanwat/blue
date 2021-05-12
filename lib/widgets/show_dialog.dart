// Flutter imports:
import 'package:flutter/material.dart';

class ShowDialog extends StatelessWidget {
  final String title, description, leftButtonText, rightButtonText;
  final Function leftButtonFunction, rightButtonFunction;
  ShowDialog({
    @required this.title,
    @required this.description,
    @required this.leftButtonText,
    @required this.rightButtonText,
    this.leftButtonFunction,
    this.rightButtonFunction,
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
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
              title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (description != "") SizedBox(height: 16.0),
            if (description != "")
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            SizedBox(height: 24.0),
            Container(
              padding: EdgeInsets.only(left: 10, right: 12, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  FlatButton(
                    height: 42,
                    minWidth: 70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: leftButtonFunction != null
                        ? leftButtonFunction
                        : () {
                            Navigator.of(context).pop(); // To close the dialog
                          },
                    child: Text(
                      leftButtonText,
                      style: TextStyle(
                          color: Theme.of(context).iconTheme.color,
                          fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  FlatButton(
                    height: 42,
                    minWidth: 70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.blue,
                    onPressed: rightButtonFunction != null
                        ? rightButtonFunction
                        : () {
                            Navigator.of(context).pop(); // To close the dialog
                          },
                    child: Text(
                      rightButtonText,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
