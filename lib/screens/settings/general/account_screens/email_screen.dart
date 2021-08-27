// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/constants/app_colors.dart';
// Package imports:
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import 'package:blue/state_management/provider_widget.dart';

class EmailScreen extends StatefulWidget {
  static const routeName = 'email';

  @override
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  TextEditingController newEmailController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  bool currentPasswordObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Theme.of(context).canvasColor,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Change Email',
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
                  onPressed: () {
                    var auth = Provider.of(context).auth;
                    auth.changeEmail(
                        newEmailController.text,
                        currentPasswordController.text,
                        context); //TODO and errors
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(color: AppColors.blue, fontSize: 18),
                  ))
            ],
          )),
      body: Container(
        height: MediaQuery.of(context).size.height -
            100 -
            MediaQuery.of(context).padding.top,
        child: Center(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
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
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return "Email can't be empty";
                      return null;
                    },
                    controller: newEmailController,
                    decoration: InputDecoration(
                      hintText: 'New Email',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
