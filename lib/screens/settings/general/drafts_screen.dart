// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/widgets/settings_widgets.dart';

class DraftsScreen extends StatefulWidget {
  static const routeName = 'drafts';
  @override
  _DraftsScreenState createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  @override
  void initState() {
    print(preferences.get('drafts'));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Drafts'),
      body: ListView(
        children: <Widget>[
          
        ],
      ),
    );
  }
}
