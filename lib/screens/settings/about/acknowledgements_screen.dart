// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/widgets/settings_widgets.dart';

class AcknowledgementsScreen extends StatefulWidget {
  static const routeName = 'acknowledgements';
  @override
  _AcknowledgementsScreenState createState() => _AcknowledgementsScreenState();
}

class _AcknowledgementsScreenState extends State<AcknowledgementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsHeader(context, 'Acknowledgements'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}
