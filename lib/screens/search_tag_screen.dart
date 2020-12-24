// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_icons/flutter_icons.dart';

class SearchTagScreen extends StatefulWidget {
  static const routeName = 'search-tag';
    @override
  _SearchTagScreenState createState() => _SearchTagScreenState();
}

class _SearchTagScreenState extends State<SearchTagScreen> {
  TextEditingController tagSearchController = TextEditingController();
  String searchTerm;
  List<String> tagResults = [];
  InkWell tagTile(String tag){
    return 
     InkWell(
       onTap: (){
         Navigator.pop(context,tag);
       },
            child: Padding(
         padding: EdgeInsets.symmetric(vertical: 5),
         child: Text('#$tag')),
     ) ;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(titleSpacing: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,leading: CupertinoNavigationBarBackButton(),automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(right: 20.0, left: 0),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(fontSize: 18,),
              onChanged: (value){
                setState(() {
          searchTerm = value;
        });
              },
              controller: tagSearchController,
              decoration: InputDecoration(
                hintText: 'Search Tags',
                hintStyle: TextStyle(fontSize: 18,color: Theme.of(context).iconTheme.color.withOpacity(0.8)),
                fillColor: Theme.of(context).cardColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(width: 0, color: Theme.of(context).backgroundColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(width: 0, color: Theme.of(context).backgroundColor),
                ),
                prefixIcon: Icon(FlutterIcons.search_oct,color: Theme.of(context).iconTheme.color,),
                
              ),
              onFieldSubmitted: null,
            ),
          ),
        ),
      ),
      body: Padding(padding: EdgeInsets.only(
        top: 10,
        left: 20,
        right: 20,
      ),
      child: Column(
          children: <Widget>
          
          [
          InkWell(
       onTap: (){
         Navigator.pop(context,tagSearchController.text);
       },
            child: Padding(
         padding: EdgeInsets.symmetric(vertical: 5),
         child: Text(searchTerm == null?'':'#$searchTerm'
         ,style: TextStyle(
           fontSize: 18
         ),
         )),
     ),if(tagResults.isEmpty)Container(
  height: MediaQuery.of(context).size.height*0.4,
  alignment: Alignment.bottomCenter,
  child:  Stack
  (
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(14.5),
        child: Icon(FlutterIcons.hashtag_faw5s,size: 16,),
      ),
       Icon(FlutterIcons.search_fea,size: 50,),
    ],
  ),
    
  ),

            
            ],
      ),
      ),
    );
  }
}
