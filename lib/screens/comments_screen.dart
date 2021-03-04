// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/providers/comment.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import '../widgets/comment.dart';
import './home.dart';
import '../services/boxes.dart';
import '../services/hasura.dart';
class CommentsScreen extends StatefulWidget {
  static const routeName = '/comments';
  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController commentsController = TextEditingController();
  bool showReplies = true;
  Post data;
  Widget commentsWidget =  circularProgress();
  buildComments(Post data)async {
   dynamic  snapshot = await Hasura.getComments(data.postId);
   print(snapshot);
        print(snapshot.length);
        List<Widget> comments = [
           Container(
             padding: EdgeInsets.only(left: 50,top: 18,bottom: 18),
                  color:Theme.of(context).backgroundColor,
                  width: MediaQuery.of(context).size.width,
                 
                     child:
                      Text(
                        'Comments',
                        style: TextStyle(
                          fontFamily: 'Techna Sans Regular',
                          fontSize: 20,
                        ),
                      ),
                    
                  ) ,
          data,
          Container(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: SwitchListTile(
                value: showReplies,
                onChanged: (newValue) {
                  setState(() {
                    showReplies = newValue;
                    PreferencesUpdate().updateBool('show_replies', newValue);
                  });
                },
                title: Text(
                  'Show Replies',
                  style: TextStyle(fontSize: 15),
                ),
                activeColor: Colors.blue,
                dense: true,
              )), Container(width: double.infinity,  color: Colors.grey[400],height: 0.4,),
        ];
        if( snapshot.length == 0){
          setState(() {
               commentsWidget = ListView(padding: EdgeInsets.only(bottom: 90,left: 0,right: 0,top: 0),
          children: comments,
        );
          });
         
        }
        snapshot.forEach((doc) {
          comments.add(Comment.fromDocument(doc,  doc['post_id'],  doc['comment_id']));
          print('d');
        });
        print(snapshot.length);
        setState(() {
           commentsWidget =  ListView(padding: EdgeInsets.only(bottom: 90,left: 0,right: 0,top: 0),
          children: comments,
        );
        });
     
   
  }

  addComments(Post data){
  Hasura.insertComment(data.postId, commentsController.text);
    commentsController.clear();
  }

  addReply(Post data, String commentId, String ownerId, {String referName}) {
    if (referName != null) {
      // commentsRef
      //     .doc(data.postId)
      //     .collection('userComments')
      //     .doc(commentId)
      //     .update(
      //   {
      //     'replies.$timestamp': {
      //       'username': currentUser.username,
      //       'comment': commentsController.text,
      //       'timeStamp': FieldValue.serverTimestamp(),
      //       'avatarUrl': currentUser.photoUrl,
      //       'userId': currentUser.id,
      //       'upvotes': 0,
      //       'downvotes': 0,
      //       'referName': referName
      //     },
      //     'repliesWordCount':
      //         FieldValue.increment(commentsController.text.length),
      //   },
      // );
    } else {
      // commentsRef
      //     .doc(data.postId)
      //     .collection('userComments')
      //     .doc(commentId)
      //     .update(
      //   {
      //     'replies.$timestamp': {
      //       'username': currentUser.username,
      //       'comment': commentsController.text,
      //       'timeStamp': timestamp,
      //       'avatarUrl': currentUser.photoUrl,
      //       'userId': currentUser.id,
      //       'upvotes': 0,
      //       'downvotes': 0,
      //     },
      //     'repliesWordCount':
      //         FieldValue.increment(commentsController.text.length),
      //   },
      // );
    }

    bool isNotPostOwner = Boxes.currentUserBox.get('user_id') == ownerId;
    if (isNotPostOwner) {
      activityFeedRef.doc(ownerId).collection('feedItems').add({
        'type': 'comment reply',
        'commentData': commentsController.text,
        'username': currentUser.username,
        'displayName': currentUser.name,
        'title': data.title,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': data.postId,
        'timestamp': timestamp,
      });
    }

    CommentNotifier().changeCommentType({'type': 'comment'});
    commentsController.clear();
  }

  @override
  void initState() {
   
    CommentNotifier().changeCommentType(
      {'type': 'comment'},
    );
    bool _showReplies = PreferencesUpdate().getBool('show_replies');
    if (_showReplies == null) {
      _showReplies = true;
    }
    showReplies = _showReplies;
    super.initState();
  }
  @override
  void didChangeDependencies() {
     data = ModalRoute.of(context).settings.arguments as Post;
   buildComments(data);
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
  
    return ChangeNotifierProvider(
      create: (_) => CommentNotifier(),
      child: Scaffold(
      
        body: SafeArea(
          child: Stack(
            children: <Widget>[
             commentsWidget,
              Column(
                children: [Expanded(child: Container(),),
                  Consumer<CommentNotifier>(
                      builder: (context, CommentNotifier notifier, child) {
                    print(notifier.commentState);
                    return Container( margin: EdgeInsets.symmetric(horizontal: 6,vertical: 6),decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),border: Border.all(width: 1,color: Colors.grey.withOpacity(0.4))),
                      child: Material(borderRadius: BorderRadius.circular(30),
                                          child: Column(mainAxisSize: MainAxisSize.min
                        ,
                          children: <Widget>[
                            if (notifier.commentState['referName'] != null)
                              Container(
                               
                                color: Theme.of(context).cardColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 10),
                                child: Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        notifier.changeCommentType({'type': 'comment'});
                                      },
                                      child: Icon(
                                        Icons.cancel,
                                        color: Colors.grey[600],
                                        size: 22,
                                      ),
                                    ),
                                    Text(
                                      'Replying ',
                                      style: TextStyle(),
                                    ),
                                    Text(
                                      '@${notifier.commentState['referName']}',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  width: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: CircleAvatar(
                                    maxRadius: 19,
                                    minRadius: 19,
                                    backgroundImage: CachedNetworkImageProvider(
                                      currentUser.avatarUrl??"https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744" ,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: TextField(
                                    focusNode: notifier.focusNode,
                                    controller: commentsController,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).iconTheme.color),
                                    maxLines: 8,
                                    maxLength: 1000,
                                    minLines: 1,keyboardType: TextInputType.multiline,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(top: 0, left: 10),
                                      hintText: notifier.commentState['type'],
                                      counter: Container(),
                                      hintStyle: TextStyle(
                                          fontSize: 18,height: 0.7,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color
                                              .withOpacity(0.8)),
                                      fillColor: Theme.of(context).cardColor,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide(
                                          width: 0,
                                          color: Theme.of(context).cardColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide(
                                          width: 0,
                                          color: Theme.of(context).cardColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: GestureDetector(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle, color: Colors.deepOrange),
                                      padding: EdgeInsets.all(6),
                                      child: Icon(
                                        FluentIcons.comment_arrow_right_20_regular,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () {
                                      print(notifier.commentState['type']);
                                      if (notifier.commentState['type'] == 'comment') {
                                        addComments(data);
                                      } else if (notifier.commentState['type'] ==
                                          'reply') {
                                        if (notifier.commentState['referName'] != null)
                                          addReply(
                                              data,
                                              notifier.commentState['commentId'],
                                              notifier.commentState['ownerId'],
                                              referName:
                                                  notifier.commentState['referName']);
                                        else {
                                          addReply(
                                            data,
                                            notifier.commentState['commentId'],
                                            notifier.commentState['ownerId'],
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
               Container(
                 margin: EdgeInsets.only(left: 6,top:9),
                 height: 36,width: 36,
                 decoration: BoxDecoration(shape: BoxShape.circle,color: Theme.of(context).canvasColor.withOpacity(0.8)),
                 child: Center(
                   child: InkWell(
                           child : Icon(
                              FluentIcons.chevron_left_24_filled,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
