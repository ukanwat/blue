import 'package:blue/constants/app_colors.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/field_decoration.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';

class GenderScreen extends StatefulWidget {
  static const routeName = 'gende';
  @override
  _GenderScreenState createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  bool loading = true;
  String gender;
  getGender() async {
    dynamic doc = await (Hasura.getUser(self: true));
    setState(() {
      if (doc['data']['users_by_pk']['gender'] != null) {
        gender = doc['data']['users_by_pk']['gender'];
      }
      if ((gender != 'Male') &&
          (gender != 'Female') &&
          (gender != '') &&
          (gender != null)) {
        custom = true;
        genderController.text = gender;
      }
      print(gender);
      loading = false;
    });
  }

  @override
  void initState() {
    getGender();
    super.initState();
  }

  bool custom = false;
  TextEditingController genderController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Gender', button: true, buttonFn: () {
        if (custom) {
          gender = genderController.text;
        }
        print('gender:');
        print(gender);
        if (gender != null) {
          Hasura.updateUser(gender: gender);
        }
        Navigator.pop(context);
      }),
      body: loading
          ? circularProgress()
          : Column(
              children: [
                ListTile(
                  onTap: () {
                    gender = 'Male';
                    setState(() {
                      custom = false;
                    });
                    print(gender);
                  },
                  title: Text('Male'),
                  trailing: Visibility(
                    visible: gender == 'Male' && !custom,
                    child: Icon(FlutterIcons.check_circle_faw5s,
                        color: AppColors.blue),
                  ),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      gender = 'Female';
                      custom = false;
                    });
                  },
                  title: Text('Female'),
                  trailing: Visibility(
                    visible: gender == 'Female' && !custom,
                    child: Icon(FlutterIcons.check_circle_faw5s,
                        color: AppColors.blue),
                  ),
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      custom = true;
                    });
                  },
                  title: Text('Custom'),
                  trailing: Visibility(
                    visible: custom,
                    child: Icon(FlutterIcons.check_circle_faw5s,
                        color: AppColors.blue),
                  ),
                ),
                if (custom)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: genderController,
                      decoration: fieldDecoration('Custom Gender'),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'This information will remain private',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                )
              ],
            ),
    );
  }
}
