import 'package:flutter/material.dart';

import 'package:blue/screens/search_results_screen.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../widgets/header.dart';
import '../models/user.dart';
import './home.dart';
import '../widgets/post.dart';
import '../widgets/progress.dart';
import 'package:blue/main.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with  AutomaticKeepAliveClientMixin<HomeScreen>,SingleTickerProviderStateMixin {
  List<Post> posts;
  TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getTimeline();
  }

  getTimeline() async {
    print(currentUser);
    QuerySnapshot snapshot = await timelineRef
        .document(currentUser.id)
        .collection('timelinePosts')
        .getDocuments();
  
    setState(() {
      posts =  snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
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
    return DefaultTabController(
length: 2,
          child: TabBarView(
            controller: tabController,
        children: <Widget>[

           Scaffold(
          backgroundColor: Theme.of(context).canvasColor,
          appBar: header(
            context,title: Text('Scrible',style: TextStyle(
              fontFamily: 'Techna Sans Regular',
      
            ),),
            actionButton: IconButton(icon: Icon(FlutterIcons.plus_ant,size: 29,),onPressed: (){
              tabController.animateTo(1);
            },),
            centerTitle: true,
         
            ),
          
          
          body: RefreshIndicator(
              onRefresh: () => getTimeline(), child: buildTimeline(),),),
            Scaffold(
              appBar: header(context,title: Text('Following',),leadingButton: IconButton(
                onPressed: (){
                  tabController.animateTo(0);
                },
                icon: Icon(FlutterIcons.back_ant,size: 29,))),
            )
        ],
      ),
    )
    
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
            
            ;
  }
}
