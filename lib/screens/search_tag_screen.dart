import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchTagScreen extends StatefulWidget {
  static const routeName = 'search-tag';
    @override
  _SearchTagScreenState createState() => _SearchTagScreenState();
}

class _SearchTagScreenState extends State<SearchTagScreen> {
  TextEditingController tagSearchController = TextEditingController();
  String searchTerm;
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
        backgroundColor: Colors.white,
        elevation: 0,leading: CupertinoNavigationBarBackButton(),automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(right: 20.0, left: 0),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(fontSize: 18),
              onChanged: (value){
                setState(() {
          searchTerm = value;
        });
              },
              controller: tagSearchController,
              decoration: InputDecoration(
                hintText: 'Search Tags',
                fillColor: Colors.grey[300],
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(width: 0, color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(width: 0, color: Colors.white),
                ),
                prefixIcon: Icon(Icons.search),
                
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
         child: Text('#$searchTerm'
         ,style: TextStyle(
           fontSize: 18
         ),
         )),
     )
            
            ],
      ),
      ),
    );
  }
}