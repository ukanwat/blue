import 'package:blue/providers/provider_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordScreen extends StatefulWidget {
  static const routeName = 'password';

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  String _currentPassword,_newPassword,_warning;
  TextEditingController currentPasswordController;
  TextEditingController newPasswordController;
  final formKey = GlobalKey<FormState>();
  bool validate() {
    final form = formKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  submit()async{
    if (validate()) {
      try {
          final auth = Provider.of(context).auth;
         await auth.changePassword(_newPassword,_currentPassword);
      } catch (e) {
        print(e);
        setState(() {
          _warning = e.message;
          print(_warning);
        });
      }
    }
   Navigator.pop(context);


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
              color: Colors.blue,
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
                      color: Colors.blue,
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
                    child: TextFormField(
                                          validator: (value) {
                        if(value.isEmpty)
                        return "current Password can't be empty";
                        return null;
                      },
                      onSaved: (value) => _currentPassword = value,
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
                    child: TextFormField(onSaved: (value) => _newPassword = value,
                      validator: (value) {
                        if(value.isEmpty)
                        return "New Password can't be empty";
                        if (value.length < 6) 
                        return "New Password must be atleast 6 characters long";
                        return null;
                      },
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
