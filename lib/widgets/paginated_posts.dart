// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/progress.dart';
import 'post.dart';

class PaginatedPosts extends StatefulWidget {
  final Query query;
  final int  length ;
  final bool isCompact;
  PaginatedPosts({
    this.query,
    this.length,
    this.isCompact,
    Key key,
  }):super(key: key);
  @override
  _PaginatedPostsState createState() => _PaginatedPostsState();
}

class _PaginatedPostsState extends State<PaginatedPosts> {
  List<Post> posts = [];
  bool loaded = false;
  DocumentSnapshot lastDoc;
  bool empty = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
     addPosts();
     _scrollController.addListener(() { 
          if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent && empty != true  && loaded != true ){
            print('sdfsefsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
            setState(() {
            addPosts();
            });
          }

     });
    super.initState();
  }
   addPosts()async{
     if(lastDoc == null ){
 var _snapshot = await widget.query.limit(widget.length).get();
       posts =_snapshot.docs.map((doc) => Post.fromDocument(doc.data(),isCompact: widget.isCompact == null? false: widget.isCompact)).toList();
         setState(() {
          
        });
       print('dwdsffffffffffffffffffffffffffffffffff');
       print(widget.query.parameters);

         if(_snapshot.docs.length == 0){
                 setState(() {
                   empty = true;
                 });
                 return;
               }
                  lastDoc = _snapshot.docs.last; 
        if(_snapshot.docs.length < widget.length ){
                 setState(() {
                  loaded = true;
                 });
                 return;
               }
     }
     else{
   var _snapshot = await widget.query.startAfterDocument(lastDoc).limit(widget.length).get();
               _snapshot.docs.forEach((doc) { 
                 posts.add(Post.fromDocument(doc.data()));
               });
              
                if(_snapshot.docs.length < widget.length ){
                 setState(() {
                  loaded = true;
                 });
                 return;
               }
                lastDoc = _snapshot.docs.last; 
     }
     
  
  
   }
  @override
  Widget build(BuildContext context) {
    return empty? emptyState(context, "Can't find any posts ", 'none'): ListView.builder(
      physics:AlwaysScrollableScrollPhysics(),
   
      controller: _scrollController,
itemCount:posts.length+1,
      itemBuilder: (context, i) {
        print(i);
        if(i == posts.length)
        return Container(
          height: 100,
          child: loaded? Center(): circularProgress(),
        );
        return posts[i];
      },
      
    );
  }
}
