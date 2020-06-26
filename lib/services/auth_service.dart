import 'dart:convert';

import 'package:blue/models/user.dart';
import 'package:blue/providers/provider_widget.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/screens/sign_in_view_screen.dart';
import 'package:blue/screens/tabs_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Stream<String> get onAuthStateChanged => _firebaseAuth.onAuthStateChanged.map(
        (FirebaseUser user) => user?.uid,
      );

  // Email & Password Sign Up
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    final currentUser = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update the username
    var userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = name;
    await currentUser.user.updateProfile(userUpdateInfo);
    await currentUser.user.reload();
    return currentUser.user.uid;
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
   
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
     _firebaseAuth.signOut();
     currentUser = null;
     Navigator.of(context).pushReplacementNamed(SignInViewScreen.routeName);
  }

  // Reset Password
  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future changePassword(String newPassword,String password) async {
    var firebaseUser = await _firebaseAuth.currentUser();
SharedPreferences preferences = await SharedPreferences.getInstance();
     String _accountType =  preferences.getString('accountType');
    if (firebaseUser != null && _accountType !=  'google') { 
        final AuthCredential credential = EmailAuthProvider.getCredential(email: currentUser.email, password: password);
         firebaseUser.reauthenticateWithCredential(credential);
       firebaseUser.updatePassword(newPassword);
        firebaseUser.reload();
      
    }
  }
    Future changeEmail(String email,String password) async {
    var firebaseUser = await _firebaseAuth.currentUser();
SharedPreferences preferences = await SharedPreferences.getInstance();
     String _accountType =  preferences.getString('accountType');
    if (firebaseUser != null && _accountType !=  'google') { 
      try{
        final AuthCredential credential = EmailAuthProvider.getCredential(email: currentUser.email, password: password);
         firebaseUser.reauthenticateWithCredential(credential);
       firebaseUser.updateEmail(email);
        firebaseUser.reload();
       usersRef.document(currentUser.id).setData({'email': email},merge: true);
      var currentUserString =  preferences.getString('currentUser');
      var currentUserMap = json.decode(currentUserString);
      currentUserMap['email'] = email;
      currentUserString =  json.encode( currentUserMap);
       preferences.setString('currentUser',currentUserString );
      preferences.reload();
      getCurrentUser();}
      catch(e){
        print(e);
      }
    }

  }

  // Create Anonymous User
  Future singInAnonymously() {
    return _firebaseAuth.signInAnonymously();
  }

  signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
    var user = (await _firebaseAuth.signInWithCredential(credential)).user;
    DocumentSnapshot doc = await usersRef.document(account.id).get();
    var username;
    if (!doc.exists) {
      username = await Navigator.of(context)
          .pushNamed(SignInScreen.googleSignInRouteName);
      usersRef.document(account.id).setData({
        'id': account.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': "",
        'timestamp': timestamp,
        'website': ""
      });
      doc = await usersRef.document(account.id).get();
    }
    Map currentUserMap = {
      'id': account.id,
      'username': username,
      'photoUrl': user.photoUrl,
      'email': user.email,
      'displayName': user.displayName,
      'bio': "",
      'website': ""
    };
     user.reload();
    String currentUserString = json.encode(currentUserMap);
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('accountType','google');
    preferences.setString('currentUser', currentUserString);
    preferences.reload();
    getCurrentUser();

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
