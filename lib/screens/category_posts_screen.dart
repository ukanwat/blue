// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/paginated_posts.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'home.dart';

class CategoryPostsScreen extends StatefulWidget {
  final String name;
  CategoryPostsScreen(this.name);
  @override
  _CategoryPostsScreenState createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends State<CategoryPostsScreen>
    with AutomaticKeepAliveClientMixin<CategoryPostsScreen> {
  List<Post> posts = [];
  bool loading = true;
  bool blank = false;
  Widget compactPosts;

  

 

    Future refreshPosts()async{
      setState(() {if(widget.name == 'All')
      compactPosts = PaginatedPosts(length: 8,query: postsRef.orderBy('timeStamp',descending: true,),isCompact: true ,key: UniqueKey(),);
      else
        compactPosts = PaginatedPosts(length: 8,query: postsRef.where('topicName',isEqualTo: widget.name).orderBy('timeStamp',descending: true,),isCompact: true ,key: UniqueKey(),);
      }); 
  }
   @override
  void initState() {
    if(widget.name == 'All')
      compactPosts = PaginatedPosts(length: 8,query: postsRef.orderBy('timeStamp',descending: true,),isCompact: true ,key: UniqueKey(),);
      else
   compactPosts =  PaginatedPosts(length: 8,query: postsRef.where('topicName',isEqualTo: widget.name).orderBy('timeStamp',descending: true,), isCompact: true,key: UniqueKey(),);
    super.initState();
  }
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
     decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).cardColor,width: 1))),
     child:compactPosts);
  }
}
