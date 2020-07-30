

import 'package:flutter/material.dart';

class SubmitState extends InheritedWidget {
  final String state; 

 SubmitState({Key key, Widget child, this.state}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static SubmitState of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<SubmitState>());
}