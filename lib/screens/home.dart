import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../screens/tabs_screen.dart';
import './create_account.dart';
import '../models/user.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final repostsRef = Firestore.instance.collection('reposts');
final savedPostsRef = Firestore.instance.collection('saved-posts');
final collectionsRef = Firestore.instance.collection('collections');
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('activityFeed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final messagesRef = Firestore.instance.collection('messages');
final timelineRef = Firestore.instance.collection('timeline');
final communitiesRef = Firestore.instance.collection('communities');
final followedTopicsRef = Firestore.instance.collection('followed-topics');
final topicsRef = Firestore.instance.collection('topics');
final postsCollectionGroupRef = Firestore.instance.collectionGroup('userPosts');
final topicPostsRef = Firestore.instance.collection('topic-posts');
final usersDatabase = FirebaseDatabase.instance.reference().child('users');
final topicPostsDatabase = FirebaseDatabase.instance.reference().child('topic-posts');
//final usersDatabase = FirebaseDatabase.instance.reference().child('users');
//final popularPostsRef = Firestore.instance.collection('popularPosts');
//final communityPostsRef = Firestore.instance.collection('communityPosts');

final Timestamp timestamp = Timestamp.now();

FirebaseAuth firebaseAuth;
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  @override
  void initState() {
    // Detects when user signed in
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error Signing in : $err');
    });
    //Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error Signing in : $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
    await  createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database(according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
//     GoogleSignInAuthentication googleAuth = await user.authentication;
// final AuthCredential credential = GoogleAuthProvider.getCredential(
//     accessToken: googleAuth.accessToken,
//     idToken: googleAuth.idToken,
// );
// FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist the we want to take them to the create account page
      final username = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );
     // 3) get username from create account, use it to make new user document in collection
    usersRef.document(user.id).setData({
      'id': user.id,
      'username': username,
      'photoUrl': user.photoUrl,
      'email': user.email,
      'displayName': user.displayName,
      'bio': "",
      'timestamp': timestamp
      
       
    }); 
    doc = await usersRef.document(user.id).get();
    }
  currentUser = User.fromDocument(doc);

   
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 250,
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Image.asset('assets/icons/appbar_appicon.png'),
                    alignment: Alignment.bottomCenter,
                  ),
                  Positioned(
                    height: 100,
                    bottom: 86,
                    left: 65,
                    child: Container(
                      child: Image.asset('assets/images/appicon_rays.png'),
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ],
                overflow: Overflow.visible,
              ),
            ),
            SizedBox(
              height: 100,
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage('assets/icons/google_signin_button.png'),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(
              height: 70,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? TabsScreen() : buildUnAuthScreen();
  }
}
