// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/services/auth_service.dart';

class Provider extends InheritedWidget {
  final AuthService auth; 

  Provider({Key key, Widget child, this.auth}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static Provider of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<Provider>());
}
