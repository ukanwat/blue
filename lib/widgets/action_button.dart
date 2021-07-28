import 'package:blue/constants/doubles.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final Function onTap;
  final Color color;
  final String text;
  final bool hide;
  const ActionButton(this.onTap, this.color, this.text, this.hide);

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool hide;

  @override
  Widget build(BuildContext context) {
    return hide == true
        ? Container(
            width: 0,
          )
        : GestureDetector(
            onTap: () {
              widget.onTap();
              if (widget.hide == true) {
                setState(() {
                  hide = true;
                });
              }
            },
            child: Container(
              height: 26,
              constraints: BoxConstraints(maxWidth: 70),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      width: Doubles.actionButtonBorder, color: widget.color)),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                        fontFamily: 'Stark Sans', fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          );
  }
}
