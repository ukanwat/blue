// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:blue/models/user.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:blue/screens/home.dart';
import 'package:blue/screens/sign_in_view_screen.dart';
import '../main.dart';
import '../screens/sign_in_screen.dart';
import 'boxes.dart';
import 'package:blue/providers/provider_widget.dart';
class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Stream<auth.User> get onAuthStateChanged => _firebaseAuth.authStateChanges();

  // GET UID
  Future<String> getCurrentUID() async {
    return _firebaseAuth.currentUser.uid;
  }
 static logout(BuildContext context) {
   var auth =  Provider.of(context).auth;
    auth.signOut(context);
  }
  // Email & Password Sign Up
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    final _currentUser = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
               
    // Update the username
    await _currentUser.user.updateProfile(displayName: name);
         currentUser = User(displayName: name,email: email);
    await _currentUser.user.reload();
    return _currentUser.user.uid;
  }

  // Email & Password Sign In
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user
        .uid;
  }

  // Sign Out
  Future signOut(BuildContext context) async {
    if(Boxes.preferenceBox != null){
 await Boxes.preferenceBox.clear();
    }
    
    await _firebaseAuth.signOut();
     currentUser = null;
     Navigator.of(context).pushReplacementNamed(SignInViewScreen.routeName);
  }

  // Reset Password
  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future changePassword(String newPassword,String password) async {
    auth.User firebaseUser = _firebaseAuth.currentUser;
    
     String _accountType = PreferencesUpdate().getString('accountType');
    if (firebaseUser != null && _accountType !=  'google') { 
        final auth.AuthCredential credential = auth.EmailAuthProvider.credential(email: currentUser.email, password: password);
         firebaseUser.reauthenticateWithCredential(credential);
       firebaseUser.updatePassword(newPassword);
        firebaseUser.reload();
      
    }
  }
    Future changeEmail(String email,String password) async {
    var firebaseUser =  _firebaseAuth.currentUser;
     String _accountType =  PreferencesUpdate().getString('accountType');
    if (firebaseUser != null && _accountType !=  'google') { 
      try{
        final auth.AuthCredential credential = auth.EmailAuthProvider.credential(email: currentUser.email, password: password);
         firebaseUser.reauthenticateWithCredential(credential);
       firebaseUser.updateEmail(email);
        firebaseUser.reload();
       usersRef.doc(currentUser.id).set({'email': email},SetOptions(merge: true));
      var currentUserMap = Boxes.currentUserBox.toMap();
      currentUserMap['email'] = email;
    Boxes.currentUserBox.putAll(  currentUserMap);
      getCurrentUser();}
      catch(e){
        print(e);
      }
    }

  }


  signInWithGoogle(BuildContext context) async {
  
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await account.authentication;
    final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
   
    var user = (await _firebaseAuth.signInWithCredential(credential)).user;
    DocumentSnapshot doc = await usersRef.doc(account.id).get();
    var username;
    if (!doc.exists) {
      username = await Navigator.of(context)
          .pushNamed(SignInScreen.googleSignInRouteName);
      usersRef.doc(account.id).set({
        'id': account.id,
        'username': username,
        'photoUrl': user.photoURL,
        'email': user.email,
        'displayName': user.displayName,
        'bio': "",
        'timestamp': timestamp,
        'website': ""
      });
      doc = await usersRef.doc(account.id).get();
    }
    Map currentUserMap = {
      'id': account.id,
      'username': username,
      'photoUrl': user.photoURL,
      'email': user.email,
      'displayName': user.displayName,
      'bio': "",
      'website': ""
    };
     user.reload();
     PreferencesUpdate().updateString('accountType','google');
     Boxes.currentUserBox.putAll(currentUserMap);

    getCurrentUser();

     var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
        Boxes.voteBox =  await Hive.openBox('votes');
   Boxes.saveBox =  await Hive.openBox('saves');
   Boxes.followingBox =  await Hive.openBox('followings');
    user.reload();
  }

  
}

class NameValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Name can't be empty";
    }
    if (value.length < 2) {
      return "Name must be at least 2 characters long";
    }
    if (value.length > 50) {
      return "Name must be less than 50 characters long";
    }
    return null;
  }
}

class EmailValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Email can't be empty";
    }
    return null;
  }
}

class UsernameValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Username can't be empty";
    }
    if (value.length < 3) return 'Username is too short';
    Pattern pattern = r'(?=[a-zA-Z0-9._]{3,30}$)(?!.*[_.]{2})[^_.].*[^_.]';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Invalid username';
    else
      return null;
  }
}

class PasswordValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Password can't be empty";
    }
    return null;
  }
}
