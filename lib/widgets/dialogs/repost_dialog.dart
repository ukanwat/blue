// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/settings_widgets.dart';

class RepostDialog extends StatefulWidget {
  final Post post;
  RepostDialog(this.post);

  @override
  _RepostDialogState createState() => _RepostDialogState();
}

class _RepostDialogState extends State<RepostDialog> {
  bool shareWithComment = true;
  TextEditingController commentController = TextEditingController();
  sharePost() async {
    //  var lastDoc = await repostsRef
    //     .doc(currentUser.id)
    //     .collection('userReposts')
    //     .orderBy('order', descending: true)
    //     .limit(1)
    //     .get();

    //    if (lastDoc.docs.length == 0) {
    //    repostsRef
    //       .doc(currentUser.id)
    //       .collection('userReposts')
    //         .doc()
    //         .set({
    //                       'order' : 1,
    //       'posts': [widget.post.postId,],
    //       'comments': [commentController.text,],
    //     });
    //   }else if(lastDoc.docs.length == 1 && lastDoc.docs.first.data()['posts'].length < 20){
    //     List<dynamic> _postIdList = lastDoc.docs.first.data()['posts'];
    //      List<dynamic> _commentsList = lastDoc.docs.first.data()['comments'];
    //     _postIdList.add(widget.post.postId);
    //      _commentsList.add(commentController.text);
    //   repostsRef
    //       .doc(currentUser.id)
    //       .collection('userReposts')
    //         .doc(lastDoc.docs.first.id)
    //         .set({
    //             'posts': _postIdList,
    //             'comments': _commentsList,
    //     });

    // }else if(lastDoc.docs.length == 1 && lastDoc.docs.first.data()['posts'].length > 19 ){
    //  repostsRef
    //       .doc(currentUser.id)
    //       .collection('userReposts')
    //         .doc()
    //         .set({ 'order' : lastDoc.docs.first.data()['order'] + 1 ,
    //        'posts': [widget.post.postId,],
    //      'comments': [commentController.text,],
    //     });
    // }

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
          color: Theme.of(context).canvasColor,
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
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Text(
                  widget.post.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            settingsSwitchListTile('Share with comment', shareWithComment,
                (newValue) {
              setState(() {
                shareWithComment = newValue;
              });
            }),
            if (shareWithComment)
              TextFormField(
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).iconTheme.color),
                controller: commentController,
                maxLines: 4,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    hintText: 'Comment',
                    hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(width: 0, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(width: 0, color: Colors.grey),
                    ),
                    contentPadding: EdgeInsets.all(6)),
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
                    style: TextStyle(color: Theme.of(context).iconTheme.color),
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
