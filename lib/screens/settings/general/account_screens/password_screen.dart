// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/constants/app_colors.dart';
// Package imports:
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import 'package:blue/state_management/provider_widget.dart';
import 'package:blue/widgets/progress.dart';

class PasswordScreen extends StatefulWidget {
  static const routeName = 'password';

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  String _currentPassword, _newPassword, _warning;
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool validate() {
    if (currentPasswordController.text == '') {
      errorText = 'Current Password is empty';
      return false;
    }
    if (newPasswordController.text == '') {
      errorText = 'New Password is empty';
      return false;
    }

    if (newPasswordController.text.length < 8) {
      errorText = 'New password must be atleast 8 chararcters long';
      return false;
    }
    return true;
  }

  String errorText;

  submit() async {
    bool b = validate();
    if (b) {
      try {
        final auth = Provider.of(context).auth;
        await auth.changePassword(newPasswordController.text,
            currentPasswordController.text, context);
      } catch (e) {
        setState(() {
          _warning = e.message;
          snackbar(_warning, context, color: Colors.red);
        });
      }

      Navigator.pop(context);
    } else {
      snackbar(errorText == null ? 'Something went wrong!' : errorText, context,
          color: Colors.red);
      errorText = null;
    }
  }

  bool currentPasswordObscure = true;
  bool newPasswordObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Theme.of(context).canvasColor,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Change Password',
              style: TextStyle(),
            ),
            automaticallyImplyLeading: false,
            leading: CupertinoNavigationBarBackButton(
              color: AppColors.blue,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: submit,
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.blue,
                    ),
                  ))
            ],
          )),
      body: Container(
        height: MediaQuery.of(context).size.height -
            100 -
            MediaQuery.of(context).padding.top,
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: currentPasswordController,
                    decoration: InputDecoration(
                      suffixIcon: currentPasswordObscure
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  currentPasswordObscure = false;
                                });
                              },
                              icon: Icon(
                                FlutterIcons.visibility_off_mdi,
                                color: Theme.of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(0.8),
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  currentPasswordObscure = true;
                                });
                              },
                              icon: Icon(FlutterIcons.visibility_mdi,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      .withOpacity(0.8))),
                      hintText: 'Current Password',
                      contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      border: OutlineInputBorder(),
                      fillColor: Theme.of(context).cardColor,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).cardColor,
                          width: 1,
                        ),
                      ),
                      hintStyle: TextStyle(
                        color:
                            Theme.of(context).iconTheme.color.withOpacity(0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Theme.of(context).cardColor, width: 1),
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    obscureText: currentPasswordObscure,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: TextField(
                    obscureText: newPasswordObscure,
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      suffixIcon: newPasswordObscure
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  newPasswordObscure = false;
                                });
                              },
                              icon: Icon(FlutterIcons.visibility_off_mdi,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      .withOpacity(0.8)))
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  newPasswordObscure = true;
                                });
                              },
                              icon: Icon(FlutterIcons.visibility_mdi,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      .withOpacity(0.8))),
                      hintText: 'New Password',
                      fillColor: Theme.of(context).cardColor,
                      hintStyle: TextStyle(
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              .withOpacity(0.8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).cardColor,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Theme.of(context).cardColor, width: 1),
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
