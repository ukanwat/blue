// // Flutter imports:
// import 'package:blue/services/preferences_update.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// // Package imports:
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';

// // Project imports:
// import 'package:blue/main.dart';
// import 'package:blue/providers/comment.dart';
// import 'package:blue/screens/home.dart';
// import 'package:blue/widgets/comment.dart';
// import 'package:blue/widgets/post.dart';
// import 'package:blue/widgets/progress.dart';

// class ExplorePostsScreen extends StatefulWidget {
//   static const routeName = 'explore-posts';
//   @override
//   _ExplorePostsScreenState createState() => _ExplorePostsScreenState();
// }

// class _ExplorePostsScreenState extends State<ExplorePostsScreen>
//     with TickerProviderStateMixin {
//   Post post;
//   Post _post;
//   List<Widget> widgets = [];

//    TextEditingController commentsController = TextEditingController();
//   bool showReplies = true;

//   buildComments(Post data) {
//     return StreamBuilder(
//       stream: null,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return circularProgress();
//         }
//         print(snapshot.data.documents.length);
//         List<Widget> comments = [Container(
//           padding: const EdgeInsets.symmetric(vertical:0.0),

//        child:   SwitchListTile(value: showReplies, onChanged: (newValue){
//          setState(() {
//                     showReplies = newValue;
//                     PreferencesUpdate().updateBool('show_replies', newValue);
//          });
//           },
//           title: Text('Show Replies',style: TextStyle(fontSize: 15),),
//           activeColor: Colors.blue,
//           dense: true,

//           )

//         )];
//         snapshot.data.documents.forEach(( doc) {
//           print(doc);
//           // comments.add(Comment.fromDocument(doc.data(),data.postId,doc.id,showReplies));
//           print('d');
//         });
//         print(snapshot.data.documents.length);
//         return ListView(
//           children: comments,
//         );
//       },
//     );
//   }

//   addComments(Post data) {
//     // commentsRef.doc(data.postId).collection('userComments').add({
//     //   'username': currentUser.username,
//     //   'comment': commentsController.text,
//     //   'timeStamp': timestamp,
//     //   'avatarUrl': currentUser.photoUrl,
//     //   'userId': currentUser.id,
//     //   'upvotes': 0,
//     //   'downvotes': 0,
//     // });
//     // TODO data['postInteractions'].postInteractions[data['postId']] = PostInteraction( data['ownerId'], false, true, false, false);
//     bool isNotPostOwner = currentUser.id == data.ownerId;
//     if (isNotPostOwner) {
//       activityFeedRef.doc(data.ownerId).collection('feedItems').add({
//         'type': 'comment',
//         'commentData': commentsController.text,
//         'username': currentUser.username,
//         'displayName': currentUser.name,
//         'title': data.title,
//         'userId': currentUser.id,
//         'userProfileImg': currentUser.photoUrl,
//         'postId': data.postId,
//         'timestamp': timestamp,
//       });
//     }
//     commentsController.clear();
//   }
//   addReply(Post data, String commentId,String ownerId,{String referName}){
//       if(referName != null){
//   //  commentsRef.doc(data.postId).collection('userComments').doc(commentId).update({'replies.$timestamp': {
//   //           'username': currentUser.username,
//   //     'comment': commentsController.text,
//   //     'timeStamp': timestamp,
//   //     'avatarUrl': currentUser.photoUrl,
//   //     'userId': currentUser.id,
//   //     'upvotes': 0,
//   //     'downvotes': 0,
//   //     'referName': referName
//   //      },
//   //        'repliesWordCount': FieldValue.increment( commentsController.text.length),
//   //      },

//   //      );
//   //     }else{
//       //      commentsRef.doc(data.postId).collection('userComments').doc(commentId).update({'replies.$timestamp': {
//       //       'username': currentUser.username,
//       // 'comment': commentsController.text,
//       // 'timeStamp': timestamp,
//       // 'avatarUrl': currentUser.photoUrl,
//       // 'userId': currentUser.id,
//       // 'upvotes': 0,
//       // 'downvotes': 0,
//       //  },
//       //    'repliesWordCount': FieldValue.increment( commentsController.text.length),
//       //  },

//       //  );
//       }

//            bool isNotPostOwner = currentUser.id == ownerId;
//     if (isNotPostOwner) {
//       activityFeedRef.doc(ownerId).collection('feedItems').add({
//         'type': 'comment reply',
//         'commentData': commentsController.text,
//         'username': currentUser.username,
//         'displayName': currentUser.name,
//         'title': data.title,
//         'userId': currentUser.id,
//         'userProfileImg': currentUser.photoUrl,
//         'postId': data.postId,
//         'timestamp': timestamp,
//       });
//     }

//         CommentNotifier().changeCommentType({'type': 'comment'});
//          commentsController.clear();

//   }
//   @override
//   void initState() {
//     CommentNotifier().changeCommentType({'type': 'comment'},);
//     bool _showReplies = PreferencesUpdate().getBool('show_replies');
//     if(_showReplies == null){
//       _showReplies = true;
//     }
//     showReplies = _showReplies;
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//     post = ModalRoute.of(context).settings.arguments as Post;
//     _post = Post(
//       contents: post.contents,
//       contentsInfo: post.contentsInfo,
//       isCompact: false,
//       ownerId: post.ownerId,
//       photoUrl: post.photoUrl,
//       postId: post.postId,
//       tags: post.tags,
//       title: post.title,
//       topicId: post.topicId,
//       topicName: post.topicName,
//       upvotes: post.upvotes,
//       username: post.username,commentsShown: true,
//     );
//  widgets = <Widget>[
//       _post,
//     ];
//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(50),
//         child: AppBar(
//           leading: CupertinoNavigationBarBackButton(
//             color: Colors.blue,
//           ),
//           backgroundColor: Theme.of(context).canvasColor,
//           elevation: 0,
//         ),
//       ),
//       body:DefaultTabController(
//         length: 2,
//         child: NestedScrollView(
//           headerSliverBuilder: (context, _) {
//             return [
//               SliverToBoxAdapter(
//                 child: _post,
//               ),
//             ];
//           },
//           body: Column(
//             children: <Widget>[
//               TabBar(
//                 indicatorColor: Colors.blue,
//                 tabs: [
//                   Tab(text: 'More'),
//                   Tab(text: 'Comments'),
//                 ],
//               ),
//               Expanded(
//                 child: TabBarView(
//                   children: [
//                     Container(),
//              ChangeNotifierProvider(      create: (_) => CommentNotifier(),
//                   child:   buildComments(post) )

//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       )

//     );
//   }
// }
