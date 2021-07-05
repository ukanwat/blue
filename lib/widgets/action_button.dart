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
        ? Container()
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
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 3.5, color: widget.color)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                child: Text(
                  widget.text,
                  style: TextStyle(
                      color: widget.color,
                      fontFamily: 'Stark Sans',
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
          );
  }
}
