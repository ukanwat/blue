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
                  borderRadius: BorderRadius.circular(10),
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

class BoxButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final Function fn;
  final double radius;
  final double margin;
  BoxButton(this.child, this.fn, {this.color, this.radius, this.margin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(margin ?? 0),
      child: InkWell(
        onTap: fn,
        borderRadius: BorderRadius.circular(radius ?? 10),
        child: Material(
          color: color ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(radius ?? 10),
          child: Padding(
            child: child,
            padding: EdgeInsets.all(5),
          ),
        ),
      ),
    );
  }
}
