import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class DeactivateAccountScreen extends StatelessWidget {
  static const routeName = 'deactivate-account';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Deactivate Account'),
      body: ListView(children: <Widget>[settingsActionTile(context, 'Deactivate Account', (){})],),
      
    );
  }
}
