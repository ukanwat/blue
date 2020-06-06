import 'package:blue/screens/home.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';

class RepostDialog extends StatefulWidget {
 final  Post post;
  RepostDialog(this.post);

  @override
  _RepostDialogState createState() => _RepostDialogState();
}

class _RepostDialogState extends State<RepostDialog> {
  bool shareWithComment = true;
TextEditingController commentController = TextEditingController();
sharePost()async{
 await  repostsRef
        .document(currentUser?.id)
        .collection('userReposts')
        .document(widget.post?.postId)
        .setData({
      'postId': widget.post?.postId,
     'ownerId': widget.post?.ownerId,
      'username': widget.post?.username,
      'contents': widget.post?.contents,
      'contentsInfo': widget.post?.contentsInfo,
      'title': widget.post?.title,
      'timeStamp': timestamp,
      'upvotes': {},                     // TODO: Remove
      'topicId': widget.post?.topicId,
      'topicName': widget.post?.topicName,
      'tags': widget.post?.tags,
      'comment': commentController.text
    }); // TODO: check if successful

     Navigator.of(context).pop();
}
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Text(
              "Share",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
               SizedBox(height: 10.0),
            Container(width: double.infinity,alignment: Alignment.center,
              child: ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                   child: Text(widget.post.title,
                   style: TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.w500
                   ),
                   ),
              ),
            ),
           
            settingsSwitchListTile('Share with comment',shareWithComment , (newValue){
            setState(() {
              shareWithComment = newValue;
            });
              
              
            }),
            TextFormField(
              textAlignVertical: TextAlignVertical.center,
              
              style: TextStyle(fontSize: 16),
              controller: commentController,
              maxLines: 4,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Comment',

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(width: 0, color: Colors.grey),

                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(width: 0, color: Colors.grey),
                ),
                contentPadding: EdgeInsets.all(6)
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(
                    'Cancel',
                  ),
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.blue,
                  onPressed: sharePost,
                  child: Text(
                    'Share',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
