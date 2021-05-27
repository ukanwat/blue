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
  Widget posts = Container(
    height: 0,
    margin: EdgeInsets.zero,
    padding: EdgeInsets.zero,
  );

  Future refreshPosts() async {
    setState(() {
      posts = Container(
        child: PaginatedPosts(
          length: 6,
          key: UniqueKey(),
          neverScroll: true,
          orderBy: "{score:desc}",
          tag: widget.tag,
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    posts = PaginatedPosts(
      length: 6,
      key: UniqueKey(),
      neverScroll: true,
      orderBy: "{score:desc}",
      tag: widget.tag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(0), margin: EdgeInsets.all(0), child: posts);
  }
}
