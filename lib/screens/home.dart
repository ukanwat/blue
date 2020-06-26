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
final followedTagsRef = Firestore.instance.collection('followed-tags');
final topicsRef = Firestore.instance.collection('topics');
final postsCollectionGroupRef = Firestore.instance.collectionGroup('userPosts');
final topicPostsCollectionGroupRef =
    Firestore.instance.collectionGroup('topicPosts');
final userPostsRef = Firestore.instance.collection('user-posts');
final usersDatabase = FirebaseDatabase.instance.reference().child('users');
final topicPostsDatabase =
    FirebaseDatabase.instance.reference().child('topic-posts');

final Timestamp timestamp = Timestamp.now();

FirebaseAuth firebaseAuth;


