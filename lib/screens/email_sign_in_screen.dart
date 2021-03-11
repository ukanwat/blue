import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:blue/services/auth_service.dart';
import './set_name_screen.dart';

class EmailSignInScreen extends StatefulWidget {
static const routeName = 'emai-sign-in';

  @override
  _EmailSignInScreenState createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  bool register = false;
  bool error =  false;
  String  id;
  Future<String> signupUser(LoginData data)async{
    register = true;
    print('Email: ${data.name}, Password: ${data.password}');
    try{
     id =  await AuthService().createUserWithEmailAndPassword(data.name ,data.password);}catch(e){
   error = true;
   return 'Something went wrong!';
 }
 return null;
    // return Future.delayed(loginTime).then((_) {
    //   if (!users.containsKey(data.name)) {
    //     return 'Username not exists';
    //   }
    //   if (users[data.name] != data.password) {
    //     return 'Password does not match';
    //   }
    //   return null;
    // });
  }

    Future<String> loginUser(LoginData data) async{
    print('Email: ${data.name}, Password: ${data.password}');
      try{
   id = await AuthService().signInWithEmailAndPassword(data.name ,data.password);}catch(e){
     error = true;
     return 'Something went wrong!';

            }
return null;
  }

  Future<String> _recoverPassword(String name) {
   
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Stark',
      logo: 'assets/images/stark-bnb-icon-wa.png',
      onLogin: loginUser,
      onSignup: signupUser,
      onSubmitAnimationCompleted: () {
        if(error)return;
        if(register){
          Navigator.pushNamed(context, SetNameScreen.routeName,);
          //AuthService().setInfo(int.parse(id));
        }else{
          AuthService().getUserFromHasura(int.parse(id), context);
        }
      },messages: LoginMessages(),
      onRecoverPassword: _recoverPassword,theme: LoginTheme(
        
        primaryColor: Theme.of(context).accentColor,bodyStyle: TextStyle(color:Colors.black),cardTheme: CardTheme(color: Colors.white)),
    );
  }
}