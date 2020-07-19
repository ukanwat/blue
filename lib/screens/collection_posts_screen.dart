import 'package:blue/screens/home.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';

class CollectionPostsScreen extends StatefulWidget {
  static const routeName  = 'collection-posts';
  @override
  _CollectionPostsScreenState createState() => _CollectionPostsScreenState();
}

class _CollectionPostsScreenState extends State<CollectionPostsScreen> {
bool hasMorePosts = true;
bool loading = false;
List<Post> posts = [];
  List<dynamic> postDocSnapshots = [];
  DocumentSnapshot lastPostDocument;
  int documentLimit = 10;
  String collectionName ;
getAllSavedPosts(String collectionName) async {
    if (!hasMorePosts) {
      print('No More posts');
      return;
    }
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    var _postGroup = await savedPostsRef
        .document(currentUser.id)
        .collection('userCollections')
        .document(collectionName)
        .collection('collectionPosts')
        .orderBy('order', descending: false)
        .getDocuments();
    List _postList = [];
    for (int l = 0; l < _postGroup.documents.length; l++) {
      _postList.add(_postGroup.documents.elementAt(l).data['posts']);
    }
    List _postFullList = [];
    for (int i = 0; i < _postList.length; i++) {
      for (int x = 0; x < _postList[i].length; x++) {
        _postFullList.add(_postList[i][x]);
      }
    }
    List<Future> postFutures = [];
    if (lastPostDocument == null) {
      for (int k = 0; k < _postFullList.length; k++) {
        postFutures.add(postsRef.document(_postFullList[k]).get());
      }
    } else {
      for (int k = 0; k < _postFullList.length; k++) {
        postFutures.add(postsRef.document(_postFullList[k]).get());
      }
    }
    postDocSnapshots = await Future.wait(postFutures);

    if (postDocSnapshots.length < documentLimit) {
      hasMorePosts = false;
    }
    if (postDocSnapshots.length == 0) {
      return;
    }
    lastPostDocument = postDocSnapshots[postDocSnapshots.length - 1];
    setState(() {
      loading = false;
      posts = posts +
          postDocSnapshots.map((doc) => Post.fromDocument(doc)).toList();
    });
  }
  buildAllSavedPosts(){
        if (loading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container();                         // TODO:
    } else {
      return ListView(children: posts);
    }
  }
  @override
  void didChangeDependencies() {
   collectionName =  ModalRoute.of(context).settings.arguments as String;
    getAllSavedPosts(collectionName );
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: header(context,
    title: Text(collectionName),
    centerTitle: true,
    elevation: 1,
    leadingButton: CupertinoNavigationBarBackButton(
      color: Colors.blue
    ),


    ),
    body: buildAllSavedPosts(),
    );
  }
}