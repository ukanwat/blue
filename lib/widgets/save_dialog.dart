import 'package:blue/screens/home.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SaveDialog extends StatefulWidget {
 final  Post post;
  SaveDialog(this.post);

  @override
  _SaveDialogState createState() => _SaveDialogState();
}

class _SaveDialogState extends State<SaveDialog> {
  bool shareWithComment = true;
TextEditingController commentController = TextEditingController();
bool isLoading = true;
List<InkWell> collectionList = [];
savePost(String collectionName)async{
 await  savedPostsRef
        .document(currentUser?.id)
        .collection('userCollections')
        .document(collectionName)
        .collection('collectionPosts')
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

}  
@override
  void initState() {
   getCollections();
    super.initState();
  }
  getCollections()async{
    DocumentSnapshot snapshot =await collectionsRef
        .document(currentUser?.id).get();
    setState(() {

    if(snapshot != null) {snapshot.data.forEach((key, value) {
         collectionList.insert(int.parse(key), InkWell(
onTap: ()async {
  await savePost(value);
  Navigator.pop(context);                // TODO dont pop if user pops using tap or back button
},
                    child: Container(
decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(5),
  color: Colors.grey[200]
),
height: 40,width: double.infinity,
margin: EdgeInsets.symmetric(vertical: 2),
             child:Center(
               child: Text(value,

                 style: TextStyle(
                   fontSize: 20
                 ),
                 ),
             ),
           ),
         ));
     });}
   
     isLoading = false;
    });

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
              "Save to Collection",
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
 SizedBox(height: 20.0),
       isLoading?
       circularProgress():
           Container(
             height:  MediaQuery.of(context).size.height*0.4 > 44*collectionList.length.toDouble()?44*collectionList.length.toDouble(): MediaQuery.of(context).size.height*4.0,
          child: ListView(
            physics: BouncingScrollPhysics(),
            children:
              collectionList
          ,
          
          ),
           ),
            SizedBox(height: 20.0),
            
                FlatButton(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
