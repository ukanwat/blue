// Flutter imports:
import 'package:blue/screens/settings/general/collection_screens/create_collection_screen.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import '../services/boxes.dart';
import '../services/hasura.dart';

class SaveDialog extends StatefulWidget {
  final Post post;
  SaveDialog(this.post);

  @override
  _SaveDialogState createState() => _SaveDialogState();
}

class _SaveDialogState extends State<SaveDialog> {
  bool shareWithComment = true;
  TextEditingController commentController = TextEditingController();
  bool isLoading = true;
  List<InkWell> collectionList = [];
  savePost(String collectionName) async {
    await Hasura.updateSavedPost(collectionName, widget.post.postId);
    Boxes.saveBox.put(widget.post.postId, collectionName);
  }

  @override
  void initState() {
    getCollections();
    super.initState();
  }

  getCollections() async {
    dynamic snapshot = await Hasura.getCollections();
    setState(() {
      if (snapshot != null) {
        snapshot.forEach((value) {
          collectionList.add(InkWell(
            onTap: () async {
              await savePost(value['collection']);
              Navigator.pop(
                  context); // TODO dont pop if user pops using tap or back button
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).cardColor),
              height: 40,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    value['collection'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ));
        });
      }

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
        constraints: BoxConstraints(maxWidth: 500),
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
              "Save to Collection",
              style: TextStyle(
                color: Theme.of(context).iconTheme.color.withOpacity(0.8),
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
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
            SizedBox(height: 20.0),
            isLoading
                ? circularProgress()
                : Container(
                    constraints: BoxConstraints.loose(Size.fromHeight(300)),
                    height: MediaQuery.of(context).size.height * 0.4 >
                            44 * collectionList.length.toDouble()
                        ? 44 * collectionList.length.toDouble()
                        : MediaQuery.of(context).size.height * 4.0,
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: collectionList,
                    ),
                  ),
            SizedBox(height: 20.0),
            FlatButton(
              minWidth: 200,
              highlightColor: Colors.blue,
              hoverColor: Colors.blue,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // To close the dialog
                Navigator.pushNamed(context, CreateCollectionScreen.routeName);
              },
              child: Text(
                'Create Collection',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
            SizedBox(height: 15.0),
            FlatButton(
              minWidth: 200,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // To close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
