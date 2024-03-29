// Flutter imports:
import 'package:flutter/material.dart';

class ShowDialog extends StatelessWidget {
  final String title,
      description,
      middleButtonText,
      topButtonText,
      bottomButtonText;
  final Function middleButtonFunction, topButtonFunction, bottomButtonFunction;
  final Widget background;
  ShowDialog(
      {@required this.title,
      @required this.description,
      @required this.topButtonText,
      this.middleButtonText,
      this.bottomButtonText,
      this.bottomButtonFunction,
      this.middleButtonFunction,
      this.topButtonFunction,
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
                    onPressed: topButtonFunction != null
                        ? topButtonFunction
                        : () {
                            Navigator.of(context).pop(); // To close the dialog
                          },
                    child: Text(
                      topButtonText,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Stark Sans'),
                    ),
                  ),
                  if (middleButtonText != null)
                    SizedBox(
                      height: 4,
                    ),
                  if (middleButtonText != null)
                    FlatButton(
                      height: 42,
                      minWidth: double.maxFinite,
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onPressed: middleButtonFunction != null
                          ? middleButtonFunction
                          : () {
                              Navigator.of(context)
                                  .pop(); // To close the dialog
                            },
                      child: Text(
                        middleButtonText,
                        style: TextStyle(
                            color: Theme.of(context).iconTheme.color,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Stark Sans',
                            fontSize: 16),
                      ),
                    ),
                  if (bottomButtonText != null)
                    SizedBox(
                      height: 4,
                    ),
                  if (bottomButtonText != null)
                    FlatButton(
                      height: 42,
                      minWidth: double.maxFinite,
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            width: 2,
                            color: Theme.of(context).cardColor,
                          )),
                      onPressed: bottomButtonFunction != null
                          ? bottomButtonFunction
                          : () {
                              Navigator.of(context)
                                  .pop(); // To close the dialog
                            },
                      child: Text(
                        bottomButtonText,
                        style: TextStyle(
                            color: Theme.of(context).iconTheme.color,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Stark Sans',
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
