import 'package:blue/widgets/post.dart' as p;
import 'package:flutter/material.dart';

import '../widgets/activity_feed_item.dart';
import '../models/user.dart';
import '../widgets/progress.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

FutureBuilder peopleResultsScreen(Future<QuerySnapshot> peopleResultsFuture,TextEditingController searchController) {
  return FutureBuilder(
    future: peopleResultsFuture,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return circularProgress();
      }
      List<UserResult> peopleResults = [];
      snapshot.data.documents.forEach((doc) {
        User user = User.fromDocument(doc);
        UserResult peopleResult = UserResult(user);
        peopleResults.add(peopleResult);
      });
      if(peopleResults.length != 0)
      {
      return Column(
        //shrinkWrap: true,
        //physics: ClampingScrollPhysics(),
        mainAxisSize: MainAxisSize.min,
        children: peopleResults,
      );}
      return Container(width: double.infinity,
        height: 100,
        child: Center(
          child: Text(
            'No Results Found for "${searchController.text}"',
            style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,

            ),
          ),
        ),
      );
    },
  );
}

FutureBuilder postsResultsScreen(Future<QuerySnapshot> postsResultsFuture,TextEditingController searchController) {
  return FutureBuilder(
    future: postsResultsFuture,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return circularProgress();
      }
      List<p.Post> postsResults = [];
      snapshot.data.documents.forEach((doc) {
        p.Post post = p.Post.fromDocument(doc);
        postsResults.add(post);
      });
      if(postsResults.length != 0)
      {
      return ListView(
        physics: NeverScrollableScrollPhysics(),
        children: postsResults,
      );
    }
    return Container(width: double.infinity,
        height: 100,
        child: Center(
          child: Text(
            'No Posts Found for "${searchController.text}"',
            style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            
            ),
          ),
        ),
      );
    }
  );
}

CustomScrollView searchResultsScreen(Future<QuerySnapshot> peopleResultsFuture,
    Future<QuerySnapshot> postsResultsFuture,TextEditingController searchController) {
  return CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.only(top: 12, left: 14, bottom: 0,right: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'People',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 18),
              ),
              SizedBox(height: 24,width: 55,
                              child: RawMaterialButton(
                  onPressed: null,
                  child: Text(
                    'More',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                  fillColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildListDelegate(
            [Container(child: peopleResultsScreen(peopleResultsFuture,searchController),),],),
      ),
       SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.only(top: 12, left: 14, bottom: 0,right: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Posts',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 18),
              ),
            SizedBox(
              height: 32,width: 38,
              child: IconButton(icon: Icon(Icons.view_stream,size: 21,), onPressed: null),),
            ],
          ),
        ),
      ),
      SliverFillRemaining(
        child: postsResultsScreen(postsResultsFuture,searchController),
      )
    ],
  );
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.black87),
              ),
            ),
          )
        ],
      ),
    );
  }
}
