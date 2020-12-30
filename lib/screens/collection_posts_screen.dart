// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';

class CollectionPostsScreen extends StatefulWidget {
  static const routeName = 'collection-posts';
  @override
  _CollectionPostsScreenState createState() => _CollectionPostsScreenState();
}

class _CollectionPostsScreenState extends State<CollectionPostsScreen> {
  bool loading = true;
  List<Post> posts = [];
  List<dynamic> postDocSnapshots = [];
  DocumentSnapshot lastDocument;
  int documentLimit = 3;
  String collectionName;
  ScrollController _controller = ScrollController();
  Future<List> getDocPosts(String _collection)async{
    if(lastDocument == null){
var _postGroup = await savedPostsRef
        .doc(currentUser.id)
        .collection('userCollections')
        .doc(_collection)
        .collection('collectionPosts')
        .orderBy('order', descending: true)
        .limit(1)
        .get();
         if(_postGroup.docs.length == 0){
          setState(() {
            loading = false;
         
          });
             return [];
        }
        lastDocument = _postGroup.docs.first;
          return _postGroup.docs.first.data()['posts'];
    }
 var _postGroup = await savedPostsRef
        .doc(currentUser.id)
        .collection('userCollections')
        .doc(_collection)
        .collection('collectionPosts')
      
        .orderBy('order', descending: true)
          .startAfterDocument(lastDocument)
        .limit(1)
        .get();
        if(_postGroup.docs.length == 0){
          setState(() {
            loading = false;
        
          });
              return [];
        }
         lastDocument = _postGroup.docs.first;
        return _postGroup.docs.first.data()['posts'];
  }
  getAllSavedPosts(String collectionName) async {
  
    if (!loading) {
      return;
    }
   
    List _postList = [];
   
    List<Future> postFutures = [];
    int postLength = 0;
    while(postLength < documentLimit){
      
      _postList = await getDocPosts(collectionName);
      postLength +=  _postList.length;
      if(!loading)
      return;
   _postList.forEach((id) {
   postFutures.add(postsRef.doc(id).get());
       });
       
    }
    postDocSnapshots = await Future.wait(postFutures);

    
   
    setState(() {
      posts = posts +
          postDocSnapshots.map((doc) => Post.fromDocument(doc.data())).toList();
    });
  }
  
  @override
  void didChangeDependencies() {
    collectionName = ModalRoute.of(context).settings.arguments as String;
    getAllSavedPosts(collectionName);
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          loading) {
        print(
            'sdfsefsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
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
      body:Container(
        color: Theme.of(context).backgroundColor,
        child: ListView(controller: _controller, children: [
                ...posts,
                if(loading)
                circularProgress(),
             if(!loading)   Container(
                    width: double.infinity,
                    height: 100,
                    color: Theme.of(context).backgroundColor),
              ]),
      ),
    );
  }
}
