import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';
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
  @override
  void didChangeDependencies() async{
   await getPosts();
    super.didChangeDependencies();
  }

  

  getPosts() async {
    print(currentUser);
    QuerySnapshot snapshot =
        await postsRef.where('topicName', isEqualTo: widget.name).get();
        print(snapshot.docs.length );
    if (snapshot.docs.length != 0) {
      setState(() {
       snapshot.docs.forEach((doc) {
         posts.add(Post.fromDocument(
            doc.data(),
            isCompact: true,
          ));
        });
        loading = false;
      });
    } else {
      setState(() {
        blank = true;
      });
    }
  }

Widget  postList() {
    if (blank)
      return emptyState(context,  "Can't find any posts", 'Bad Gateway');
    else if (loading)
      return circularProgress();
    else
      return ListView(children: posts);
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return postList();
  }
}
