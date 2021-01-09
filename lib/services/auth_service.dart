// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:blue/models/user.dart';
import 'package:blue/screens/verify_email_screen.dart';
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
  static bool verifyingEmail = false;
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Stream<auth.User> get onAuthStateChanged => _firebaseAuth.authStateChanges();

  // GET UID
  getCurrentUID() {
   String uid =  _firebaseAuth.currentUser.uid;
   return uid;
  }
 static logout(BuildContext context) async{
   var auth =  Provider.of(context).auth;
     userSignedIn = false;
   await auth.signOut(context);
   await Boxes.clearBoxes();
  }

  // Email & Password Sign Up
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name,BuildContext context) async {
    final _currentUser = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
             
    // Update the username
    await _currentUser.user.updateProfile(displayName: name);
         currentUser = User(name: name,email: email,id:_currentUser.user.uid );
         
    await _currentUser.user.reload();
    verifyingEmail = true;
        Navigator.of(context).pushNamed(VerifyEmailScreen.routeName);
        try{  await _currentUser.user.sendEmailVerification();}catch(e){
              logout(context);
        }
 
               Navigator.of(context).pop();
              verifyingEmail = false;
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
  getUserFromFirestore(String id,BuildContext context)async{
var _doc = await usersRef.doc(id).get();

if(Boxes.currentUserBox == null){
 await Boxes.openCurrentUserBox();
}else if(!Boxes.currentUserBox.isOpen){
await Boxes.openCurrentUserBox();
}
  _doc.data().forEach((key, value) async{ 
    if(key != 'timestamp')
await Boxes.currentUserBox.put(key, value);
});
if( !_doc.data().containsKey('username')){
  String  username = await Navigator.of(context)
          .pushNamed(SignInScreen.googleSignInRouteName);
      await usersRef.doc(id).set({'username':username},SetOptions(merge: true));
      Boxes.currentUserBox.put('username', username);
}

Boxes.currentUserBox.put('userSignedIn', true);
 userSignedIn = true;
currentUser = User.fromDocument(Boxes.currentUserBox.toMap());
 }
  setUserToFirestore(String id, String name, String email,)async{
   await usersRef.doc(id).set({'id': id,'displayName': name, "email": email,},SetOptions(merge: true));
  }
  signInWithGoogle(BuildContext context) async {
  
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await account.authentication;
    final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
  
    var user = (await _firebaseAuth.signInWithCredential(credential)).user;
    
   
    await setUserToFirestore(account.id, user.displayName, user.email);
  await getUserFromFirestore(account.id,context);
     await  Boxes.openBoxes();
        PreferencesUpdate().updateString('accountType','google');
       await  setCustomClaimToken(user);
 Hasura.insertPreferences();
    user.reload();
  }
  setCustomClaimToken(auth.User _user)async{
    return;
   var stream = metadataRef.snapshots().where((snap) => snap.docs.first.id == _user.uid);
    await stream.first;
Hasura.jwtToken = await  _user.getIdToken();
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
