import 'package:flutter/material.dart';

import 'package:blue/screens/search_results_screen.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../widgets/header.dart';
import '../models/user.dart';
import './home.dart';
import '../widgets/post.dart';
import '../widgets/progress.dart';
import 'package:blue/main.dart';
import 'tag_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with
        AutomaticKeepAliveClientMixin<HomeScreen>,
        SingleTickerProviderStateMixin {
  List<Post> posts;

  bool topicLoading = true;
  @override
  void initState() {
    super.initState();
    getTimeline();
  }

  getTimeline() async {
    print(currentUser);
    QuerySnapshot snapshot = await timelineRef
        .document(currentUser.id)
        .collection('timelinePosts')
        .getDocuments();

    setState(() {
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  showTagsSheet() {
 
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: Container(
          height: 240,
          width: MediaQuery.of(context).size.width,
          decoration: new BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    child: Text('Tags you Follow',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17)),
                  ),
                  IconButton(
                      icon: Icon(Icons.keyboard_arrow_down,
                          size: 26, color: Theme.of(context).iconTheme.color),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              ),
              Expanded (child:TagsWrap()),
            ],
          ),
        ),
      ),
    );
  }
   


  
  
  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container();
    } else {
      return ListView(children: posts);
    }
  }

  // buildUsersToFollow() {
  //   return StreamBuilder(
  //     stream:
  //         usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData) {
  //         return circularProgress();
  //       }
  //       List<UserResult> userResults = [];
  //       snapshot.data.documents.forEach((doc) {
  //         User user = User.fromDocument(doc);
  //         final bool isAuthUser = currentUser.id == user.id;
  //         final bool isFollowingUser = followingList.contains(user.id);
  //         // remove auth user from recommended list
  //         if (isAuthUser) {
  //           return;
  //         } else if (isFollowingUser) {
  //           return;
  //         } else {
  //           UserResult userResult = UserResult(user);
  //           userResults.add(userResult);
  //         }
  //       });
  //       return Container(
  //         color: Theme.of(context).accentColor.withOpacity(0.2),
  //         child: Column(
  //           children: <Widget>[
  //             Container(
  //               padding: EdgeInsets.all(12.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: <Widget>[
  //                   Icon(
  //                     Icons.person_add,
  //                     color: Theme.of(context).primaryColor,
  //                     size: 30.0,
  //                   ),
  //                   SizedBox(
  //                     width: 8.0,
  //                   ),
  //                   Text(
  //                     "Users to Follow",
  //                     style: TextStyle(
  //                       color: Theme.of(context).primaryColor,
  //                       fontSize: 30.0,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Column(children: userResults),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  bool get wantKeepAlive => true;
  @override
  Widget build(context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: header(
        context,
        title: Text(
          'Scrible',
          style: TextStyle(
            fontFamily: 'Techna Sans Regular',
          ),
        ),
        actionButton: IconButton(
          icon: Icon(
            FlutterIcons.plus_ant,
            size: 29,
          ),
          onPressed: () {
            showTagsSheet();
          },
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );

    // Scaffold(
    //     backgroundColor: Theme.of(context).canvasColor,
    //     appBar: header(
    //       context,title: Text('Scrible',style: TextStyle(
    //         fontFamily: 'Techna Sans Regular',

    //       ),),
    //       centerTitle: true,

    //       ),

    //     body: RefreshIndicator(
    //         onRefresh: () => getTimeline(), child: buildTimeline(),),)

    // ;
  }
}

class TagsWrap extends StatefulWidget {
  @override
  _TagsWrapState createState() => _TagsWrapState();
}

class _TagsWrapState extends State<TagsWrap> {
      List<String> tags = [];
  List<Widget> tagChips = [];
  bool tagLoading = true;
  
  @override
  void initState() {
        getFollowedTags();
    super.initState();
  }
       getFollowedTags() async {
    var tagsDoc = await followedTagsRef.document(currentUser.id).get();
    List<String> followedTags = [];
    setState(() {
      tagLoading = false;
      tags = tagsDoc.data.keys.toList();
      for (int i = 0; i < tags.length; i++) {
        followedTags.add(tags[i]);
        tagChips.add(InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed(TagScreen.routeName, arguments: tags[i]);
          },
          child: Chip(padding: EdgeInsets.all(12),
            label: Text(
              tags[i],
              style: TextStyle(color: Theme.of(context).iconTheme.color,fontSize: 18),
            ),
            backgroundColor: Theme.of(context).cardColor,
          ),
        ));
      }
    });
    if(preferences == null)
 preferences = await SharedPreferences.getInstance();
    preferences.setStringList('followed_tags', followedTags);
  }
  @override
  Widget build(BuildContext context) {
    return tagLoading? circularProgress():Container(
  
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: SingleChildScrollView(
              child: Wrap(
          spacing: 10,runSpacing: 12,
          children: tagChips,),
      ),
    );
  }
}