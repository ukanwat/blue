// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/providers/provider_widget.dart';
import '../services/auth_service.dart';
import 'package:blue/widgets/header.dart';
import 'verify_email_screen.dart';

enum AuthFormType { signIn, signUp, googleSignIn,reset }

class SignInScreen extends StatefulWidget {
  static const signInRouteName = 'email-sign-in';
  static const signUpRouteName = 'email-sign-up';
  static const googleSignInRouteName = 'google-sign-in';
  final AuthFormType authFormType;

  SignInScreen({Key key, @required this.authFormType}) : super(key: key);
  @override
  _SignInScreenState createState() =>
      _SignInScreenState(authFormType: this.authFormType);
}

class _SignInScreenState extends State<SignInScreen> {
  AuthFormType authFormType;

  _SignInScreenState({this.authFormType});

  final formKey = GlobalKey<FormState>();
  String _email, _password, _name,_username, _warning;
  void switchFormState(String state) {
    formKey.currentState.reset();
    if (state == "signUp") {
      setState(() {
        authFormType = AuthFormType.signUp;
      });
    } else {
      setState(() {
        authFormType = AuthFormType.signIn;
      });
    }
  }

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

  void submit() async {
    if (validate()) {
      try {
        final auth = Provider.of(context).auth;
        if (authFormType == AuthFormType.signIn) {
          String uid = await auth.signInWithEmailAndPassword(_email, _password);
          print("Signed In with ID $uid");
          //   usersRef.document(user.id).setData({
          //   'id': user.id,
          //   'username': username,
          //   'photoUrl': user.photoUrl,
          //   'email': user.email,
          //   'displayName': user.displayName,
          //   'bio': "",
          //   'timestamp': timestamp
          // });
     //     Navigator.of(context).pushReplacementNamed('/home');         TODO:
        } else if (authFormType == AuthFormType.reset) {
          await auth.sendPasswordResetEmail(_email);
          print("Password reset email sent");
          _warning = "A password reset link has been sent to $_email";
          setState(() {
            authFormType = AuthFormType.signIn;
          });
        }else if(authFormType == AuthFormType.signUp){
          
         await auth.createUserWithEmailAndPassword(
              _email, _password, _name,context);
      
           

          Navigator.of(context).pushReplacementNamed('/home');
        }else{
                  Navigator.of(context).pop(_username);
                 
        }
      } catch (e) {
        print(e);
        setState(() {
          _warning = e.message;
        });
      }
    }
  }
    Widget showAlert() {
    if (_warning != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: Text(
                _warning,
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _warning = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }


  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: buildHeaderText(),
      body: Container(
        color: Theme.of(context).backgroundColor,
        height: _height,
        width: _width,
        child: Column(
          children: <Widget>[
           showAlert(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 60),
              child: Form(
                key: formKey,
                child: Column(
                  children: buildInputs() + buildButtons(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  PreferredSize buildHeaderText() {
    String _headerText;
    if (authFormType == AuthFormType.signUp) {
      _headerText = "Create New Account";
    }else if (authFormType == AuthFormType.reset) {
      _headerText = "Reset Password";
    }  else if (authFormType == AuthFormType.signIn){
      _headerText = "Sign In";
    } else{
      _headerText = "Create Username";
    }
    return header(
      context,
      centerTitle: true,
      title: Text(
        _headerText,
      ),
      leadingButton: CupertinoNavigationBarBackButton(color: Colors.blue),
    );
  }

  List<Widget> buildInputs() {
    List<Widget> textFields = [];
     if (authFormType == AuthFormType.reset) {
      textFields.add(
        TextFormField(
          validator: EmailValidator.validate,
          style: TextStyle(fontSize: 22.0),
          decoration: buildSignUpInputDecoration("Email"),
          onSaved: (value) => _email = value,
        ),
      );
      textFields.add(SizedBox(height: 20));
      return textFields;
    }
        if (authFormType == AuthFormType.googleSignIn) {
      textFields.add(
        TextFormField(
          validator: UsernameValidator.validate,
          style: TextStyle(fontSize: 22.0),
          decoration: buildSignUpInputDecoration("Username"),
          onSaved: (value) => _username = value,

        ),
      );
      textFields.add(SizedBox(height: 20));
      return textFields;
    }
    // if were in the sign up state add name
    if (authFormType == AuthFormType.signUp) {
      textFields.add(
        TextFormField(
          validator: NameValidator.validate,
          style: TextStyle(fontSize: 22.0),
          decoration: buildSignUpInputDecoration("Name"),
          onSaved: (value) => _name = value,
        ),
      );
      textFields.add(SizedBox(height: 20));
    }

    // add email & password
    textFields.add(
      TextFormField(
        validator: EmailValidator.validate,
        style: TextStyle(fontSize: 22.0),
        decoration: buildSignUpInputDecoration("Email"),
        onSaved: (value) => _email = value,
      ),
    );
    textFields.add(SizedBox(height: 20));
    textFields.add(
      TextFormField(
        validator: PasswordValidator.validate,
        style: TextStyle(fontSize: 22.0),
        decoration: buildSignUpInputDecoration("Password"),
        obscureText: true,
        onSaved: (value) => _password = value,
      ),
    );
    textFields.add(SizedBox(height: 20));

    return textFields;
  }

  InputDecoration buildSignUpInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: Theme.of(context).iconTheme.color.withOpacity(0.8)),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      focusColor: Theme.of(context).cardColor,
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide:
              BorderSide(color: Theme.of(context).cardColor, width: 0.0)),
      contentPadding:
          const EdgeInsets.only(left: 14.0, bottom: 15.0, top: 15.0),
    );
  }

  List<Widget> buildButtons() {
    String _switchButtonText, _newFormState, _submitButtonText;
    bool _showForgotPassword = false;
    if (authFormType == AuthFormType.signIn) {
      _switchButtonText = "Create New Account";
      _newFormState = "signUp";
      _submitButtonText = "Sign In";
      _showForgotPassword = true;
    } else if (authFormType == AuthFormType.reset) {
      _switchButtonText = "Return to Sign In";
      _newFormState = "signIn";
      _submitButtonText = "Submit";
    } else if(authFormType == AuthFormType.signUp){
      _switchButtonText = "Have an Account? Sign In";
      _newFormState = "signIn";
      _submitButtonText = "Sign Up";
    }else{
          _switchButtonText = '';
      _newFormState = "googleSignIn";
      _submitButtonText = "Submit";
    }

    return [
      Container(
        margin: EdgeInsets.symmetric(vertical: 30),
        width: double.infinity,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              _submitButtonText,
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ),
          onPressed: submit,
        ),
      ),
      showForgotPassword(_showForgotPassword),
      Visibility(
        visible: _switchButtonText != '' ,
              child: FlatButton(
          child: Text(_switchButtonText,
              style: TextStyle(
                  color: Theme.of(context).iconTheme.color.withOpacity(0.6))),
          onPressed: () {
            switchFormState(_newFormState);
          },
        ),
      )
    ];
  }
   Widget showForgotPassword(bool visible) {
    return Visibility(
      child: FlatButton(
        child: Text(
          "Forgot Password?",
        style: TextStyle(
                color: Theme.of(context).iconTheme.color.withOpacity(0.6)),
        ),
        onPressed: () {
          setState(() {
            authFormType = AuthFormType.reset;
          });
        },
      ),
      visible: visible,
    );
  }
}
