// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

//TODO:imp set these thing up!
final String supaPass = "Kg8UJ&nz^EXh";
final GoogleSignIn googleSignIn = GoogleSignIn();
final authRef = FirebaseFirestore.instance.collection('auth');

final preferencesRef = FirebaseFirestore.instance.collection('preferences');
final usersRef = FirebaseFirestore.instance.collection('users');
final metadataRef = FirebaseFirestore.instance.collection('metadata');
final postsRef = FirebaseFirestore.instance.collection('posts');
