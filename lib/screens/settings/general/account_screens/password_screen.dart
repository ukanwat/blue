import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordScreen extends StatefulWidget {
  static const routeName = 'password';

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  TextEditingController currentPasswordController;

  TextEditingController newPasswordController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,centerTitle: true,
            title: Text(
              'Change Password',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            automaticallyImplyLeading: false,
            leading: CupertinoNavigationBarBackButton(
              color: Colors.grey,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[FlatButton(onPressed: (){
            
              }, child: Text(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: currentPasswordController,
                    decoration: InputDecoration(
                      hintText: 'Current Password',
                      contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      border: OutlineInputBorder(),fillColor: Colors.grey[200],
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    onSubmitted: null,
                    obscureText: true,
                  ),
                ),
                 Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: TextField(obscureText: true,
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      hintText: 'New Password',
                      contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    onSubmitted: null,
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
