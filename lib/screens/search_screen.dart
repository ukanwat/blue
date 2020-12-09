import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:blue/main.dart';
import './home.dart';
import './search_results_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> peopleResultsFuture;
  Future<QuerySnapshot> postsResultsFuture;
  bool recentSearchesLoading = false;
  handleSearch(String query) {
    Future<QuerySnapshot> people = usersRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .limit(5)
        .get();
    setState(() {
      peopleResultsFuture = people;
    });
    Future<QuerySnapshot> posts = postsCollectionGroupRef
        .where('title', isGreaterThanOrEqualTo: query)
        .get();
    setState(() {
      postsResultsFuture = posts;
    });
    usersDatabase
        .child(currentUser.id)
        .child('recent-searches')
        .child(searchController.text)
        .set({'text': searchController.text,
        'time': ServerValue.timestamp
        });
  }
 List items = [];
 
 Widget getRecentSearches(){
    var recentSearches = usersDatabase
        .child(currentUser.id)
        .child('recent-searches');
   return FutureBuilder(
        future: recentSearches
        .limitToFirst(10).once(),
        builder: (context, snapshot) {
           if (snapshot.hasData) {
        items.clear();
        Map<dynamic, dynamic> values = snapshot.data.value;
       if(values == null){
         return Container();
       }
        values.forEach((key, values) {
            items.add(values);
        });
        return new ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    key: UniqueKey(),
                title: Text(items[index]['text'],
                
                ),trailing: IconButton(icon: Icon(Icons.clear,
                color: Theme.of(context).iconTheme.color,
                ),
                onPressed: (){
                  setState(() {
               recentSearches.child(items[index]['text']).set(null);
             items.removeAt(index);       
                  });
                },
                ),
                );
            });
        }
        return CircularProgressIndicator();

 
        });
  }

  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => searchController.clear());
  }

  PreferredSize buildSearchField(context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: Container(
          margin: EdgeInsets.all(6),
          width: 15,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor,),
          child: IconButton(
              iconSize: 18,
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.blue,
                size: 18,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        elevation: 1,
        backgroundColor: Theme.of(context).canvasColor,
        title: Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 1),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(fontSize: 18),
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color:  Theme.of(context).iconTheme.color.withOpacity(0.8),
                ),
                fillColor: Theme.of(context).cardColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(width: 0, color: Theme.of(context).cardColor,),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(width: 0, color: Theme.of(context).cardColor,),
                ),
                prefixIcon: Icon(
      FlutterIcons.search_oct,
      size: 22,
      color: Colors.grey,
    ),
                suffixIcon: IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: clearSearch,
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.grey,
                  ),
                ),
              ),
              onFieldSubmitted: handleSearch,
            ),
          ),
        ),
      ),
    );
  }

  Container recentSearches() {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 10,
              ),
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
       peopleResultsFuture == null && postsResultsFuture == null
          ?   getRecentSearches()  : Container()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: buildSearchField(context),
      body: peopleResultsFuture == null && postsResultsFuture == null
          ? recentSearches()
          :
          searchResultsScreen(
              peopleResultsFuture, postsResultsFuture, searchController,
              context
              ),
    );
  }
}
