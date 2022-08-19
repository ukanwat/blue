import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/field_decoration.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DateOfBirthScreen extends StatefulWidget {
  static const routeName = 'date-of-birth';
  @override
  _DateOfBirthScreenState createState() => _DateOfBirthScreenState();
}

class _DateOfBirthScreenState extends State<DateOfBirthScreen> {
  TextEditingController controller = TextEditingController();
  DateTime date;
  bool loading = true;
  DateTime initDate;
  getDOB() async {
    dynamic doc = await (Hasura.getUser(self: true));
    setState(() {
      if (doc['data']['users_by_pk']['dob'] != null) {
        initDate = DateTime.tryParse(doc['data']['users_by_pk']['dob']);
      }

      loading = false;
    });
  }

  @override
  void initState() {
    getDOB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar:
          settingsHeader(context, 'Date Of Birth', button: true, buttonFn: () {
        if (date != null) {
          Hasura.updateUser(dob: '${date.year}-${date.month}-${date.day}');
        }
        Navigator.pop(context);
      }),
      body: loading
          ? circularProgress()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DateTimeFormField(
                    decoration: fieldDecoration('MM/DD/YYYY'),
                    mode: DateTimeFieldPickerMode.date,
                    initialValue: initDate ?? DateTime.now(),
                    autovalidateMode: AutovalidateMode.always,
                    validator: (e) {
                      if (((e?.year ?? DateTime.now().year) - 50) >
                          (DateTime.now().year - 10)) {
                        return 'You are too Young';
                      }
                      return null;
                    },
                    onDateSelected: (DateTime value) {
                      date = value;
                    },
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
