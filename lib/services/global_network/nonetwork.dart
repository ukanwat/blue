import 'package:blue/services/global_network/bottomsheet.dart';
import 'package:blue/services/global_network/connectivity_status.dart';
import 'package:blue/services/global_network/displaytype.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ConnectivityStatus { WiFi, Cellular, Offline }

class NetworkSensitive extends StatelessWidget {
  final Widget child;
  final Displaytype type;
  final Widget errorScreen;

  NetworkSensitive({
    @required this.child,
    this.type,
    this.errorScreen,
  });

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    if (connectionStatus == ConnectivityStatus.WiFi) {
      return child;
    }

    if (connectionStatus == ConnectivityStatus.Cellular) {
      return child;
    }

    if (type == Displaytype.bottomSheet) {
      return NoNetworkBottomSheet(child: child);
    }

    return child;
  }
}
