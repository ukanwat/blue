import 'package:blue/models/topic_list_tile.dart';
import 'package:blue/screens/search_tag_screen.dart';
import 'package:blue/widgets/custom_image.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/show_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class SelectTopicScreen extends StatefulWidget {
  static const routeName = 'select-topic';

  @override
  _SelectTopicScreenState createState() => _SelectTopicScreenState();
}

class _SelectTopicScreenState extends State<SelectTopicScreen> {
  String contentCategoryValue;
  bool isSwitched = false;
  bool isLoading = false;
  int noOfFollowedTopicListTiles;
  List<TopicListTile> followedTopicsListTile = [];
  bool topicSelected = false;
  bool postSubmitting = false;
  List<Widget> tagChips = [];
  List<String> tags = [];
  @override
  void initState() {
    getFollowedTopics();
    super.initState();
  }
  addTag()async{
   Navigator.of(context).pushNamed(SearchTagScreen.routeName)
   .then((value){
     setState(() {
      tags.add(value);
       tagChips.add(Chip(
         label: Text(value),
       ));
     });
   })
   ;
  }
  getFollowedTopics() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await followedTopicsRef
        .document('${currentUser.id}')
        .collection('userFollowedTopics')
        .getDocuments();

    setState(() {
      isLoading = false;
      noOfFollowedTopicListTiles = snapshot.documents.length;
      snapshot.documents.forEach((doc) {
        followedTopicsListTile.add(
          TopicListTile(doc['name'], doc['imageUrl'], doc['id']),
        );
      });
    });
  }

  TopicListTile selectedTopicTile;
  @override
  Widget build(BuildContext context) {
    final postData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'Select Topic',
            style: TextStyle(color: Colors.white),
          ),
          leading: Container(
            margin: EdgeInsets.all(5),
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.grey,
            ),
          ),
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              margin: EdgeInsets.all(5),
              alignment: Alignment.center,
              child: FlatButton(
                onPressed: () {
                  if (selectedTopicTile != null) {
                      setState(() {
                      showDialog(
                        barrierDismissible: false,
                        // useRootNavigator: false,
                        context: context,
                        builder: (BuildContext context) => WillPopScope(
                          onWillPop: () async {
        return false;
      }, 
      child: Dialog( shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0.0,
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 40, horizontal: 20),
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
                              child: Column( mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  circularProgress(),
                                  SizedBox(height: 15),
                                  Text('Submitting...')
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                    postData['post-function'](
                        selectedTopicTile.name, selectedTopicTile.id,
                        tags
                        );
                  
                  }
                },
                child: Text(
                  'Post',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: selectedTopicTile == null
                          ? Colors.grey
                          : Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[ SizedBox(
            height: 8,
          ),
          Row(
            children: <Widget>[
              SizedBox(width: 16,),
              Text('Add Tags',
              style: TextStyle(
               fontSize: 16
             ),
              ),
              SizedBox(width: 5,),
              Transform.scale(
                scale: 1.8,
                              child: Container(
                                height: 30,
                                width: 30,
                                child: IconButton(icon: Icon(Icons.add
                ,size: 12,
                ), onPressed: addTag,
                iconSize: 12,
                ),
                              ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16
            ),
            child: Wrap(
              runSpacing: 6,
              spacing: 6,
                     children: 
                           tagChips
                     ,
            ),
          ),
          SizedBox(
            height: 10,
          ),
           Padding(
             padding: const EdgeInsets.only(
               left: 16
             ),
             child: Text('Select Topic'
             ,style: TextStyle(
               fontSize: 16
             ),
             ),
           ),
             
              SizedBox(
            height: 10,
          ),
          isLoading
              ? circularProgress()
              : ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (_, i) {
                    return ListTile(
                      enabled: true,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: cachedNetworkImage(
                            context, followedTopicsListTile[i].imageUrl),
                      ),
                      title: Text(
                        followedTopicsListTile[i].name,
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      trailing: selectedTopicTile == followedTopicsListTile[i]
                          ? Icon(
                              Icons.check,
                              color: Colors.blue,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          if (selectedTopicTile == followedTopicsListTile[i]) {
                            selectedTopicTile = null;
                          } else {
                            selectedTopicTile = followedTopicsListTile[i];
                          }
                        });
                      },
                    );
                  },
                  itemCount: followedTopicsListTile.length,
                )
        ],
      ),
    );
  }
}
