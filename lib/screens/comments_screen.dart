import 'package:blue/providers/comment.dart';
import 'package:blue/widgets/custom_image.dart';
import 'package:blue/widgets/header.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

import './home.dart';
import '../widgets/comment.dart';

class CommentsScreen extends StatefulWidget {
  static const routeName = '/comments';
  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController commentsController = TextEditingController();
  bool showReplies = true;

 
  buildComments(Post data) {
    return StreamBuilder(
      stream: commentsRef
          .document(data.postId)
          .collection('userComments')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        print(snapshot.data.documents.length);
        List<Widget> comments = [data,Container(
          padding: const EdgeInsets.symmetric(vertical:0.0),

       child:   SwitchListTile(value: showReplies, onChanged: (newValue){
         setState(() {
                    showReplies = newValue;
                    preferences.setBool('show_replies', newValue);
         });        
          },
          title: Text('Show Replies',style: TextStyle(fontSize: 15),),
          activeColor: Colors.blue,
          dense: true,

          )
      
        )];
        snapshot.data.documents.forEach((doc) {
          print(doc);
          comments.add(Comment.fromDocument(doc,data.postId));
          print('d');
        });
        print(snapshot.data.documents.length);
        return ListView(
          children: comments,
        );
      },
    );
  }
 
  addComments(Post data) {
    commentsRef.document(data.postId).collection('userComments').add({
      'username': currentUser.username,
      'comment': commentsController.text,
      'timeStamp': timestamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id,
      'upvotes': 0,
      'downvotes': 0,
    });
    // TODO data['postInteractions'].postInteractions[data['postId']] = PostInteraction( data['ownerId'], false, true, false, false);
    bool isNotPostOwner = currentUser.id == data.ownerId;
    if (isNotPostOwner) {
      activityFeedRef.document(data.ownerId).collection('feedItems').add({
        'type': 'comment',
        'commentData': commentsController.text,
        'username': currentUser.username,
        'displayName': currentUser.displayName,
        'title': data.title,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': data.postId,
        'timestamp': timestamp,
      });
    }
    commentsController.clear();
  }
  addReply(Post data, String commentId,String ownerId,{String referName}){
      if(referName != null){
   commentsRef.document(data.postId).collection('userComments').document(commentId).updateData({'replies.$timestamp': {
            'username': currentUser.username,
      'comment': commentsController.text,
      'timeStamp': timestamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id,
      'upvotes': 0,
      'downvotes': 0,
      'referName': referName
       },
         'repliesWordCount': FieldValue.increment( commentsController.text.length),
       },

     
       
       );
      }else{
           commentsRef.document(data.postId).collection('userComments').document(commentId).updateData({'replies.$timestamp': {
            'username': currentUser.username,
      'comment': commentsController.text,
      'timeStamp': timestamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id,
      'upvotes': 0,
      'downvotes': 0,
       },
         'repliesWordCount': FieldValue.increment( commentsController.text.length),
       },

     
       
       );
      }
    
           bool isNotPostOwner = currentUser.id == ownerId;
    if (isNotPostOwner) {
      activityFeedRef.document(ownerId).collection('feedItems').add({
        'type': 'comment reply',
        'commentData': commentsController.text,
        'username': currentUser.username,
        'displayName': currentUser.displayName,
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
    CommentNotifier().changeCommentType({'type': 'comment'},);
    bool _showReplies = preferences.getBool('show_replies');
    if(_showReplies == null){
      _showReplies = true;
    }
    showReplies = _showReplies;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var data = ModalRoute.of(context).settings.arguments as Post;

    return ChangeNotifierProvider(
      create: (_) => CommentNotifier(),
          child:Scaffold(
      appBar: header(context,
          title: Text('comments'),
          centerTitle: false,
          leadingButton: CupertinoNavigationBarBackButton()),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
            child:  buildComments(data)),
            Divider(
              height: 1,
              thickness: 0.7,

            ),
           Consumer<CommentNotifier>(
            builder: (context, CommentNotifier notifier, child) {
    print(notifier.commentState);
    return Column(
      children: <Widget>[
       if(notifier.commentState['referName']!= null) Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(vertical:2.0,horizontal: 10),
          child: Row(
            children: <Widget>[
               GestureDetector(
                 onTap: (){
                   notifier.changeCommentType({'type': 'comment'});
                 },
                                child: Icon(Icons.cancel,
              color: Colors.grey[600],
              size: 22,),
               ),
                Text('Replying ',
                style: TextStyle(),),
             Text('@${notifier.commentState['referName']}',
                style: TextStyle(color:Colors.blue),),
              
             
            ],
          ),
        ),
        SizedBox(height: 8,),
        Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[SizedBox(width: 5,),Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: CircleAvatar(
                        maxRadius: 19,
                        minRadius: 19,
                        backgroundImage:  CachedNetworkImageProvider(
                         currentUser.photoUrl,
                        ),
              ),
                  ),SizedBox(width: 5,),
               Expanded(
                            child: TextField(
                             focusNode: notifier.focusNode,
                              controller: commentsController,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).iconTheme.color),
                              maxLines: 6,
                              maxLength: 2000,
                              minLines: 1,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(top: 5, left: 10),
                                hintText: notifier.commentState['type'],

                                counter: Container(),
                                hintStyle: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        .withOpacity(0.8)),
                                fillColor: Theme.of(context).cardColor,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                              ),
                            ),
                        ),SizedBox(width: 5,),
Padding(
  padding: const EdgeInsets.only(top: 5),
  child:   GestureDetector(child: Container(
  
                      decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.blue),
  
                      padding: EdgeInsets.all(6),
  
                      child: Icon(FlutterIcons.check_bold_mco,
  
                      color: Colors.white,
  
                      ),
  
                    ),
  
                    onTap: (){
  print(notifier.commentState['type'] );
                      if(notifier.commentState['type'] == 'comment'){ addComments(data);}else if(notifier.commentState['type'] == 'reply'){

                        if(notifier.commentState['referName'] != null )
                        addReply(data,notifier.commentState['commentId'],notifier.commentState['ownerId'],referName:notifier.commentState['referName']);
                        else
                        {
                            addReply(data,notifier.commentState['commentId'],notifier.commentState['ownerId'],);
                        }
                      }
  
                    },
  
                    ),
),
SizedBox(width: 5,),
              ],),
      ],
    );})
           
          ],
        ),
      ),
     ) );
  }
}
