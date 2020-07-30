import 'dart:async';

import 'package:blue/models/topic_list_tile.dart';
import 'package:blue/providers/submit_state.dart';
import 'package:blue/providers/theme.dart';
import 'package:blue/screens/search_tag_screen.dart';
import 'package:blue/widgets/custom_image.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
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

  addTag() async {
    Navigator.of(context).pushNamed(SearchTagScreen.routeName).then((value) {
      if(value != null)
      setState(() {
        tags.add(value);
        tagChips.add(Chip(
          label: Text(value),
        ));
      });
    });
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
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
        
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(
            'Post Settings',
            style: TextStyle(),
          ),
          leading: IconButton(
              icon: Icon(FlutterIcons.ios_arrow_back_ion,size: 30,
                  color: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.grey,
            ),
          
          actions: <Widget>[ FlatButton(
                onPressed: () {
                  if (selectedTopicTile != null) {
                    setState(() {
                      showDialog(
                        barrierDismissible: true,
                        // useRootNavigator: false,
                        context: context,
                        builder: (BuildContext context) =>
                         WillPopScope(
                          onWillPop: () async {
                            return true;
                          },
                          child: Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0.0,
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 25, horizontal: 15),
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
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 30),
                                    child: Icon(FlutterIcons.cloud_upload_sli,size: 80,),
                                  ),
                                  Container(
                                    height: 4,width: MediaQuery.of(context).size.width-140,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                    child: LinearProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
backgroundColor: Colors.transparent,),
                                  ), 
                                  SizedBox(height: 15),
                                  SubmitText(),
                                ],
                              ),
                            ),
                          ),
                        )
                      );
                    });

                        
                    postData['post-function'](
                        selectedTopicTile.name, selectedTopicTile.id, tags);
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
            
          ],
        ),
      ),
      body: SingleChildScrollView(
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 8,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                Text(
                  'Tags',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  width: 8,
                ),GestureDetector(
                  onTap: (){
                    addTag();
                  },
                                child: Container(
                      height: 26,
                      width: 26,
                      decoration: BoxDecoration(color: Colors.blue,borderRadius: BorderRadius.circular(5)),
                      child: Icon(
                          Icons.add,
                          size: 24,color: Colors.white
                        ),
                      
                    ),
                ),
                
              ],
            ), if(tagChips.length >0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                children: tagChips,
              ),
            )           
else
Container(
  height: 120,
  alignment: Alignment.center,
  child: Column(mainAxisSize: MainAxisSize.min,
    children: <Widget>[Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(FlutterIcons.tag_ant,size: 25,),
    ),
        Text('Add Tags (atleast 1)',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
    ],
  ),),
            SizedBox(
              height: 10,
            ),
            Divider(color: Colors.grey,height: 0.3,),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Select Topic',
                style: TextStyle(fontSize: 16),
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
                        enabled: true,dense: true,
                        title: Text(
                          followedTopicsListTile[i].name,
                          style: TextStyle( fontSize: 20),
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
      ),
    );
  }
}


class SubmitText extends StatefulWidget {
  @override
  _SubmitTextState createState() => _SubmitTextState();
}

class _SubmitTextState extends State<SubmitText> {
  @override
  Widget build(BuildContext context) {
    String submitState = Provider.of<SubmitState>(context).state;
              return  Text(submitState ,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500)
      );
}}