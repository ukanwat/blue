// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import '../services/hasura.dart';

class CollectionPostsScreen extends StatefulWidget {
  static const routeName = 'collection-posts';
  @override
  _CollectionPostsScreenState createState() => _CollectionPostsScreenState();
}

class _CollectionPostsScreenState extends State<CollectionPostsScreen> {
  bool loaded = false;
  List<dynamic> posts = [];
  List<dynamic> postDocSnapshots = [];
  String collectionName;
  ScrollController _controller = ScrollController();
  int offset = 0;

  getAllSavedPosts(String collectionName) async {
    dynamic _data = await Hasura.getCollectionPosts(collectionName, offset);
    offset = offset + _data.length;
    if (_data.length < 8) {
      setState(() {
        loaded = true;
      });
    }
    setState(() {
      posts =
          posts + _data.map((doc) => Post.fromDocument(doc['post'])).toList();
    });
  }

  @override
  void didChangeDependencies() {
    collectionName = ModalRoute.of(context).settings.arguments as String;
    getAllSavedPosts(collectionName);
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !loaded) {
        setState(() {
          getAllSavedPosts(collectionName);
        });
      }
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(
          context,
          title: Text(collectionName),
          centerTitle: true,
          elevation: 1,
          leadingButton: CupertinoNavigationBarBackButton(color: Colors.blue),
        ),
        body: Container(
            color: Theme.of(context).backgroundColor,
            child: ListView.builder(
              controller: _controller,
              itemBuilder: (context, i) {
                if (i == posts.length && !loaded) {
                  return circularProgress();
                }
                return posts[i];
              },
              itemCount: loaded ? posts.length : posts.length + 1,
            )));
  }
}
