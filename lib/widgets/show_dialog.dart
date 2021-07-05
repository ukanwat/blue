// Flutter imports:
import 'package:flutter/material.dart';

class ShowDialog extends StatelessWidget {
  final String title, description, leftButtonText, rightButtonText;
  final Function leftButtonFunction, rightButtonFunction;
  final bool noLeft;
  final Widget background;
  ShowDialog(
      {@required this.title,
      @required this.description,
      @required this.leftButtonText,
      @required this.rightButtonText,
      this.leftButtonFunction,
      this.rightButtonFunction,
      this.noLeft,
      this.background});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
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
        child: Stack(
          children: [
            if (background != null)
              Container(
                child: background,
                width: double.maxFinite,
                height: double.maxFinite,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  FlatButton(
                    height: 42,
                    minWidth: double.maxFinite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Theme.of(context).accentColor,
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
                  if (noLeft != true)
                    SizedBox(
                      height: 4,
                    ),
                  if (noLeft != true)
                    FlatButton(
                      height: 42,
                      minWidth: double.maxFinite,
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onPressed: leftButtonFunction != null
                          ? leftButtonFunction
                          : () {
                              Navigator.of(context)
                                  .pop(); // To close the dialog
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
