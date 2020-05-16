
import 'package:blue/widgets/progress.dart';
import 'package:flutter/material.dart';

import './home.dart';
import '../widgets/comment.dart';

class CommentsScreen extends StatefulWidget {
  static const routeName = '/comments';

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController commentsController = TextEditingController();

  buildComments(Map<String, dynamic> data) {
   
    return StreamBuilder( 
      stream: commentsRef
          .document(data['postId'])
          .collection('comments')
          //.orderBy('', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
       
        if (!snapshot.hasData) {
          return circularProgress();
          
        } print(snapshot.data.documents.length);
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          print(doc);
          comments.add(Comment.fromDocument(doc));print('d');
        }); print(snapshot.data.documents.length);
        return ListView(
          children: comments,
        );
      },
     
    );
  }

  addComments(Map<String, dynamic> data) {
    commentsRef.document(data['postId']).collection('comments').add({
      'username': currentUser.username,
      'comment': commentsController.text,
      'timeStamp': timestamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id
    });
    bool isNotPostOwner = currentUser.id != data[data['postOwnerId']];
    if(isNotPostOwner){
    activityFeedRef.document(data['postOwnerId']).
    collection('feedItems').add(
      {
        'type': 'comment',
        'commentData': commentsController.text,
      'username': currentUser.username,
      'userId': currentUser.id,
      'userProfileImg': currentUser.photoUrl,
      'postId': data['postId'],
      'timestamp': timestamp
      }
    );}
    commentsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var data =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return Scaffold(
      body: SafeArea(
        child: Column( 
          children: <Widget>[
            Expanded(child: buildComments(data)),
            Divider(),
            ListTile(
              title: TextFormField(
                controller: commentsController,
                decoration: InputDecoration(labelText: 'Write a comment'),
              ),
              trailing: OutlineButton(
                onPressed: () => addComments(data),
                borderSide: BorderSide.none,
                child: Text('Post'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
