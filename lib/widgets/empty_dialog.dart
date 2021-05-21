// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/screens/home.dart';

class EmptyDialog extends StatefulWidget {
  final Widget child;
  final bool noHorizontalPadding;
  final Color color;
  EmptyDialog(this.child, {this.noHorizontalPadding, this.color});

  @override
  _EmptyDialogState createState() => _EmptyDialogState();
}

class _EmptyDialogState extends State<EmptyDialog> {
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
              horizontal: widget.noHorizontalPadding == true ? 0 : 15),
          decoration: new BoxDecoration(
            color: widget.color == null
                ? Theme.of(context).canvasColor
                : widget.color,
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
          child: widget.child),
    );
  }
}
