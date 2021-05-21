// Flutter imports:
import 'package:blue/services/preferences_update.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/settings_widgets.dart';

class ActivityScreen extends StatefulWidget {
  static const routeName = 'activity';
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool trackActivity = true;
  bool setPrivate = false;
  @override
  void initState() {
    bool _setPrivate = PreferencesUpdate().getBool('set_private');
    bool _trackActivity = PreferencesUpdate().getBool('track_activity');
    print(_setPrivate);
    print(_trackActivity);
    if (_setPrivate != null) setPrivate = _setPrivate;
    if (_trackActivity != null) trackActivity = _trackActivity;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Activity'),
      body: ListView(
        children: <Widget>[
          settingsSwitchListTile('Set your profile private', setPrivate,
              (newValue) {
            //TODO
            PreferencesUpdate()
                .updateBool('set_private', newValue, upload: true);
            setState(() {
              setPrivate = newValue;
            });
          }),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).iconTheme.color.withOpacity(0.16),
                  width: 1),
            )),
          ),
          settingsSwitchListTile('Personalised recommendations', trackActivity,
              (newValue) {
            PreferencesUpdate()
                .updateBool('track_activity', newValue, upload: true);
            setState(() {
              trackActivity = newValue;
            });
          }),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).iconTheme.color.withOpacity(0.16),
                  width: 1),
            )),
          ),
        ],
      ),
    );
  }
}
