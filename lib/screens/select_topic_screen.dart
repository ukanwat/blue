import 'package:blue/models/topic_list_tile.dart';
import 'package:blue/widgets/custom_image.dart';
import 'package:blue/widgets/progress.dart';
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
   @override
  void initState() {
    getFollowedTopics();
    super.initState();
  }
  getFollowedTopics() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await followedTopicsRef.document('${currentUser.id}').collection('userFollowedTopics').getDocuments();

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
    final postData = ModalRoute.of(context).settings.arguments as Map<String,dynamic>;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            'Select Topic',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon:Icon(Icons.arrow_back_ios), onPressed: (){
            Navigator.pop(context);
            },
            color: Colors.grey,
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
                onPressed: (){
                  if(selectedTopicTile!=null){

                   print(selectedTopicTile.name);
                  postData['post-function'](selectedTopicTile.name,selectedTopicTile.id); 
                  }
                  },
                child: Text(
                  'Post',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: selectedTopicTile==null?Colors.grey: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          isLoading? circularProgress():
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (_,i){
        return    ListTile(
      enabled: true,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: cachedNetworkImage(context,followedTopicsListTile[i].imageUrl ),),
        title: Text(followedTopicsListTile[i].name,style: TextStyle(color: Colors.black,fontSize: 20),
        
        ),
        trailing: selectedTopicTile == followedTopicsListTile[i]? Icon(Icons.check,color: Colors.blue,): null,
        onTap: (){
          setState(() {
            if(selectedTopicTile == followedTopicsListTile[i]){
              selectedTopicTile = null;

            }else {
              
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
