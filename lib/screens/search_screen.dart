import 'package:flutter/material.dart';

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
  handleSearch(String query) {
    Future<QuerySnapshot> people = usersRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .limit(5)
        .getDocuments();
    setState(() {
      peopleResultsFuture = people;
    });
 Future<QuerySnapshot> posts = postsCollectionGroupRef
        .where('title', isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      postsResultsFuture = posts;
    });

  }

  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => searchController.clear());
  }

  Icon searchIcon() {
    return Icon(
      Icons.search,
      size: 22,
      color: Colors.grey,
    );
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
              BoxDecoration(shape: BoxShape.circle, color: Colors.grey[300]),
          child: IconButton(
              iconSize: 18,
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).primaryColor,
                size: 18,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        elevation: 1,
        backgroundColor: Colors.white,
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
                fillColor: Colors.grey[300],
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(width: 0, color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(width: 0, color: Colors.white),
                ),
                prefixIcon: searchIcon(),
                suffixIcon: IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: clearSearch,
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey,
                  ),
                  iconSize: 22,
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
    List<String> recentSearches = [];
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
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (_, i) => Row(
              children: <Widget>[
                SizedBox(
                  height: 15,
                  child: Text(recentSearches[i]),
                ),
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () => {},
                )
              ],
            ),
            itemCount: recentSearches.length,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(context),
      body: peopleResultsFuture == null && postsResultsFuture == null
          ? recentSearches()
          :
          //  Column(
          //   children: <Widget>[
          searchResultsScreen(peopleResultsFuture,postsResultsFuture),

      // ],),
    );
  }
}
