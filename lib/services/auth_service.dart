// Dart imports:
import 'dart:convert';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Project imports:
import 'package:blue/models/user.dart';
import 'package:blue/providers/provider_widget.dart';
import 'package:blue/providers/verify_email.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/screens/set_name_screen.dart';
import 'package:blue/screens/settings/notification/push_notifications_screen.dart';
import 'package:blue/screens/settings/notification/push_notifications_screen.dart';
import 'package:blue/screens/show_screen.dart';
import 'package:blue/screens/sign_in_view_screen.dart';
import 'package:blue/screens/tabs_screen.dart';
import 'package:blue/screens/verify_email_screen.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/empty_dialog.dart';
import 'package:blue/widgets/progress.dart';
import '../main.dart';
import '../screens/sign_in_screen.dart';
import 'boxes.dart';
import 'push_notifications.dart';

// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  static final auth.FirebaseAuth firebaseAuth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Stream<auth.User> get onAuthStateChanged => firebaseAuth.authStateChanges();
  final authRef = FirebaseFirestore.instance.collection('auth');
  // GET UID
  getCurrentUID() {
    String uid = firebaseAuth.currentUser.uid;
    return uid;
  }

  static logout(BuildContext context) async {
    await Hasura.updateUser(deleteToken: true);
    await Functions().updateEmail();
    var auth = Provider.of(context).auth;
    userSignedIn = false;
    await auth.signOut(context);
    await Boxes.clearBoxes();
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.stark.social.service',
          redirectUri: Uri.parse('https://www.stark.social')),
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = auth.OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    _user =
        (await auth.FirebaseAuth.instance.signInWithCredential(oauthCredential))
            .user;

    await Functions().updateEmail();
    bool hasuraUserExists = await Hasura.userExists(_user.uid);
    return hasuraUserExists;
  }

  // Email & Password Sign Up
  Future<String> createUserWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    var _currentUser;
    try {
      _currentUser = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      snackbar(e.message, context, color: Colors.red);
      return null;
    }
    var _user = _currentUser.user;
    try {
      await _currentUser.user.sendEmailVerification();
    } catch (e) {
      // logout(context);
    }

    return _currentUser.user.uid;
  }

  // Email & Password Sign In
  Future<String> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    String uid;
    try {
      uid = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user
          .uid;

      try {
        Functions().updateEmail();
      } catch (e) {}
    } catch (e) {
      snackbar(e.message, context);
    }

    return uid;
  }

  // Sign Out
  Future signOut(BuildContext context) async {
    if (Boxes.preferenceBox != null) {
      await Boxes.preferenceBox.clear();
    }

    await firebaseAuth.signOut();
    currentUser = null;
    Navigator.of(context).pushReplacementNamed(SignInViewScreen.routeName);
  }

  // Reset Password
  Future sendPasswordResetEmail(String email) async {
    return firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future sendVerifyEmail(String email) async {
    return await firebaseAuth.currentUser.sendEmailVerification(
        auth.ActionCodeSettings(
            url: "https://www.stark.social/verify?email=$email",
            dynamicLinkDomain: "https://starkapp.page.link",
            androidInstallApp: true,
            handleCodeInApp: true));
  }

  Future changePassword(
      String newPassword, String password, BuildContext context) async {
    auth.User firebaseUser = firebaseAuth.currentUser;
    bool error = false;
    String _accountType = PreferencesUpdate().getString('accountType');
    if (firebaseUser != null && _accountType != 'google') {
      final auth.AuthCredential credential = auth.EmailAuthProvider.credential(
          email: currentUser.email, password: password);
      await firebaseUser.reauthenticateWithCredential(credential);
      try {
        firebaseUser.updatePassword(newPassword);
      } catch (e) {
        error = true;
        snackbar(e.message, context, color: Colors.red);
      }
      firebaseUser.reload();
    }
    if (!error) {
      snackbar('Congratulations! Password change successful', context);
    }
  }

  Future changeEmail(
      String email, String password, BuildContext context) async {
    bool error = false;
    var firebaseUser = firebaseAuth.currentUser;
    String _accountType = PreferencesUpdate().getString('accountType');
    if (firebaseUser != null && _accountType != 'google') {
      try {
        final auth.AuthCredential credential =
            auth.EmailAuthProvider.credential(
                email: currentUser.email, password: password);
        await firebaseUser.reauthenticateWithCredential(credential);
        await firebaseUser.verifyBeforeUpdateEmail(
          email,
        );
        firebaseUser.reload();

        var currentUserMap = Boxes.currentUserBox.toMap();
        currentUserMap['email'] = email;
        Boxes.currentUserBox.putAll(currentUserMap);
        getCurrentUser();
      } catch (e) {
        error = true;
      }
    }
    if (!error) {
      snackbar(
          'We just sent you a verification link on your new email address.',
          context);
      Navigator.pop(context);
    }
  }

  getUserFromHasura(int id, BuildContext context) async {
    var _doc = await Hasura.getUser(id: id);

    if (Boxes.currentUserBox == null) {
      await Boxes.openCurrentUserBox();
    } else if (!Boxes.currentUserBox.isOpen) {
      await Boxes.openCurrentUserBox();
    }
    _doc['data']['users_by_pk'].forEach((key, value) async {
      if (key != 'timestamp') await Boxes.currentUserBox.put(key, value);
    });

    Boxes.currentUserBox.put('userSignedIn', true);
    userSignedIn = true;
    currentUser = User.fromDocument(Boxes.currentUserBox.toMap());
  }

  signInWithFacebook(BuildContext context) async {
    // final LoginResult result = await FacebookAuth.instance.login();
    // // Create a credential from the access token
    final fb = FacebookLogin();

// Log in
    final res = await fb.logIn();

    final FacebookAccessToken accessToken = res.accessToken;
    print('Access token: ${accessToken.token}');
    final auth.OAuthCredential credential =
        auth.FacebookAuthProvider.credential(accessToken.token);
    // Once signed in, return the UserCredential
    _user = (await auth.FirebaseAuth.instance.signInWithCredential(credential))
        .user;

    await Functions().updateEmail();
    bool hasuraUserExists = await Hasura.userExists(_user.uid);
    return hasuraUserExists;
  }

  signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await account.authentication;
    final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );

    _user = (await firebaseAuth.signInWithCredential(credential)).user;
    await Functions().updateEmail();
    bool hasuraUserExists = await Hasura.userExists(_user.uid);
    return hasuraUserExists;
  }

  auth.User _user;
  signInContinue(BuildContext context, bool exists, var result) async {
    progressOverlay(context: context).show();

    auth.User user = _user;
    _user = null;
    Map info = {};
    if (!exists) {
      info = await listenCreateUser(user.uid, context);

      userSigningUp = true;

      await createHasuraUser(
          user.uid, info['user_id'], user.email, user.displayName, result);
      Hasura.insertPreferences(
        user.uid,
      );
    } else {
      var _doc = await authRef.where('uid', isEqualTo: user.uid).get();
      info['user_id'] = _doc.docs.first.data()['user_id'];
    }
    progressOverlay(context: context).dismiss();
    Hasura.jwtToken = await user.getIdToken(true);
    await getUserFromHasura(info['user_id'], context); //TODO
    await Boxes.openBoxes();
    PreferencesUpdate().updateString('accountType', 'google');
    await setCustomClaimToken(user);
    await setPreferences();
    Navigator.pushReplacementNamed(context, TabsScreen.routeName);
    userSignedIn = true;

    user.reload();
  }

  setPreferences() async {
    // dynamic data = await Hasura.getAllPreferences();
    // data.forEach((key, value) {
    //   PreferencesUpdate().updateString(key, value);
    // });
  }

  setCustomClaimToken(auth.User _user) async {
    Hasura.jwtToken = await _user.getIdToken();
  }

  listenCreateUser(String uid, BuildContext context) async {
    //TODO subscription
    var doc = await authRef.where('uid', isEqualTo: uid).get();
    int i = 0;
    if (doc.docs.length == 0) {
      progressOverlay(context: context).show();
      while (doc.docs.length == 0 && i != 60) {
        //TODO show error after 120 sec
        Future.delayed(Duration(seconds: 2));
        doc = await authRef.where('uid', isEqualTo: uid).get();
        i++;
      }
      progressOverlay(context: context).dismiss();
    }
    return doc.docs.first.data();
  }

  createHasuraUser(String uid, int userId, String email, String displayName,
      String username) async {
    await Hasura.createUser(email, displayName, username, userId, uid);
  }

  Future<String> loginUser(LoginData data, BuildContext context) async {
    userSignedIn = false;
    progressOverlay(context: context).show();

    String a = await AuthService()
        .signInWithEmailAndPassword(data.name, data.password, context);
    if (a == null) {
      progressOverlay(context: context).dismiss();
      return null;
    }
    var _user;
    while (_user == null) {
      _user = AuthService.firebaseAuth.currentUser;
      Future.delayed(Duration(seconds: 1));
    }
    progressOverlay(context: context).dismiss();
    if (!_user.emailVerified) {
      await navigatorKey.currentState.pushNamed(ShowScreen.routeName);
    }
    progressOverlay(context: context).show();
    bool hasuraUserExists = await Hasura.userExists(_user.uid);
    if (!hasuraUserExists) {
      userSigningUp = true;
      Map info = await AuthService().listenCreateUser(_user.uid, context);
      progressOverlay(context: context).dismiss();
      dynamic result = await navigatorKey.currentState
          .pushNamed(SetNameScreen.routeName, arguments: {"provider": "email"});
      progressOverlay().show();
      await createHasuraUser(_user.uid, info['user_id'], data.name,
          result['name'], result['username']);

      Hasura.jwtToken = await _user.getIdToken(true);
      await AuthService().getUserFromHasura(info['user_id'], context); //TODO
      // signingIn = false;
      await Boxes.openBoxes();
      PreferencesUpdate().updateString('accountType', 'email');
      await AuthService().setCustomClaimToken(_user);

      Hasura.insertPreferences(_user.uid);
      await setPreferences();
      progressOverlay().dismiss();
      Navigator.pushReplacementNamed(context, TabsScreen.routeName);
      userSignedIn = true;
      _user.reload();
    } else {
      Hasura.jwtToken = await _user.getIdToken(true);
      int _userId = await Hasura.getUserId(uid: _user.uid);
      await AuthService().getUserFromHasura(_userId, context); //TODO

      await Boxes.openBoxes();
      PreferencesUpdate().updateString('accountType', 'email');
      await AuthService().setCustomClaimToken(_user);
      await setPreferences();
      progressOverlay(context: context).dismiss();
      Navigator.pushReplacementNamed(context, TabsScreen.routeName);
      userSignedIn = true;
      _user.reload();
    }

    userSignedIn = true;
    return null;
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
