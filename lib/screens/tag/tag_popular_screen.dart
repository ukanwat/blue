// Flutter imports:
import 'package:blue/widgets/paginated_posts.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import '../home.dart';

class TagPopularScreen extends StatefulWidget {
  final String tag;
  TagPopularScreen(this.tag);
  @override
  _TagPopularScreenState createState() => _TagPopularScreenState();
}

class _TagPopularScreenState extends State<TagPopularScreen> {
 Widget posts = Container();
 
 Future refreshPosts()async{
      setState(() {
        posts = PaginatedPosts(length: 4,query: postsRef.where('tags',arrayContains: widget.tag).orderBy('upvotes',descending: true,),key: UniqueKey(),neverScroll: true,);
      }); 
  }

  @override
  void didChangeDependencies() {
   
    super.didChangeDependencies();

    posts = PaginatedPosts(length: 4,query: postsRef.where('tags',arrayContains: widget.tag).orderBy('upvotes',descending: true,),key: UniqueKey(),neverScroll: true,);
   
  }
  @override
  Widget build(BuildContext context) {
    return 
        Container(
              child: posts
        );
  }
}
