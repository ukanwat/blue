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

class AllSavedPostsScreen extends StatefulWidget {
  static const routeName  = 'all-saved-posts';
  @override
  _AllSavedPostsScreenState createState() => _AllSavedPostsScreenState();
}

class _AllSavedPostsScreenState extends State<AllSavedPostsScreen> {
 bool loading = true;
  List<Post> posts = [];
  List<dynamic> postDocSnapshots = [];
  DocumentSnapshot lastDocument;
  int documentLimit = 3;
  ScrollController _controller = ScrollController();
  Future<List> getDocPosts()async{
    if(lastDocument == null){
var _postGroup = await savedPostsRef
        .doc(currentUser.id)
        .collection('all')
        .orderBy('order', descending: true)
        .limit(1)
        .get();
        print(_postGroup.docs.first.data()['posts']);
         if(_postGroup.docs.length == 0){
             print('ssssssssssss');
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
        .collection('all')
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
  getAllSavedPosts() async {
  
    if (!loading) {
      return;
    }
   
    List _postList = [];
    
    List<Future> postFutures = [];
  int postLength = 0;
    while(postLength < documentLimit){
      _postList = await getDocPosts();
      postLength  =     postLength + _postList.length;
      if(!loading)
      return;
      print( postLength );
   _postList.forEach((id) {
     print(id);

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
    getAllSavedPosts();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          loading) {
    
        setState(() {
          getAllSavedPosts();
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
        title: Text('All Saved'),
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
