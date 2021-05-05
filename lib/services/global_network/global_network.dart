library global_network;

import 'package:blue/services/global_network/displaytype.dart';
import 'package:blue/services/global_network/nonetwork.dart';
import 'package:flutter/material.dart';

class GlobalNetwork extends StatelessWidget {
  final Widget child;
  final Displaytype type;
  final Widget errorScreen;

  const GlobalNetwork(
      {Key key, @required this.child, this.type, this.errorScreen})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return NetworkSensitive(child: child, type: type, errorScreen: errorScreen);
  }
}
