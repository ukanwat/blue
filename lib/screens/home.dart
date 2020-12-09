import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final preferencesRef = FirebaseFirestore.instance.collection('preferences');
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final postsVotersRef = FirebaseFirestore.instance.collection('votes');
final repostsRef = FirebaseFirestore.instance.collection('reposts');
final savedPostsRef = FirebaseFirestore.instance.collection('saved-posts');
final collectionsRef = FirebaseFirestore.instance.collection('collections');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('activityFeed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final messagesRef = FirebaseFirestore.instance.collection('messages');
final timelineRef =
    FirebaseFirestore.instance.collection('timeline'); //**fix timeline posts
final communitiesRef = FirebaseFirestore.instance.collection('communities');
final followedTopicsRef = FirebaseFirestore.instance.collection('followed-topics');
final followedTagsRef = FirebaseFirestore.instance.collection('followed-tags');
final topicsRef = FirebaseFirestore.instance.collection('topics');
final postsCollectionGroupRef = FirebaseFirestore.instance.collectionGroup('userPosts');
final topicPostsCollectionGroupRef =
    FirebaseFirestore.instance.collectionGroup('topicPosts');
final userPostsRef = FirebaseFirestore.instance.collection('user-posts');
final accountReportsRef = FirebaseFirestore.instance.collection('account-reports');
final commentReportsRef = FirebaseFirestore.instance.collection('comment-reports');
final suggestionsRef = FirebaseFirestore.instance.collection('suggestions');
final bugsRef = FirebaseFirestore.instance.collection('bugs');
final usersDatabase = FirebaseDatabase.instance.reference().child('users');
final topicPostsDatabase =
    FirebaseDatabase.instance.reference().child('topic-posts');
final postReportsRef = FirebaseFirestore.instance.collection('post-reports');
final Timestamp timestamp = Timestamp.now();

FirebaseAuth firebaseAuth;
