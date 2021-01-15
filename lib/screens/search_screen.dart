// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/progress.dart';
import './home.dart';
import './search_results_screen.dart';
import '../services/hasura.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>{
  List _list;
  QuerySnapshot searches;
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> peopleResultsFuture;
  Future<QuerySnapshot> postsResultsFuture;
  bool recentSearchesLoading = false;
  Widget recentSearchesWidget;
  bool searching = false;
  bool resultsLoading = true; 
  handleSearch(String query)async {
    setState(() {
      if (!searching) {
        searching = true;
      }
    resultsLoading = true;

    });
    await Hasura.insertSearch(query);
    resultsLoading = false;
  }
  List<Widget> posts = [];
   List<Widget> userTiles = [];
    List<Widget> tags = [];

  bool loading = true;
  getRecentSearches() async {
    dynamic _recentSearches = await Hasura.getSearches(10);
    print(_recentSearches);

    setState(() {
      loading = false;
      recentSearchesWidget = new ListView.builder(
          shrinkWrap: true,
          itemCount: _recentSearches.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Container(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Recent Searches',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
                ),
              );
            }
            return ListTile(
              key: UniqueKey(),
              title: Text(
                _recentSearches[index - 1]['text'],
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () async {
                  setState(() {
                    Hasura.deleteSearch(
                        _recentSearches[index - 1]['search_id']);
                    _recentSearches.removeAt(index - 1);
                  });
                },
              ),
            );
          });
    });
  }

  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => searchController.clear());
  }
  PreferredSize buildSearchField(context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(searching?90.0:50),
      child: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        bottom: !searching? PreferredSize(child: Container(),preferredSize: Size.fromHeight(0),):  TabBar(indicatorColor: Colors.deepOrange,
        indicatorPadding: EdgeInsets.symmetric(vertical: 4,horizontal: 20),
        indicatorWeight: 2.0,
              tabs: [
                Container(height: 40,
                  child: Center(
                    child: Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(FluentIcons.star_16_regular),
                        Text('Top',style: TextStyle(fontSize: 17,),)
                      ],
                    ),
                  ),
                ),
                 Container(height: 40,
                  child: Center(
                  child: Row(
                    children: [
                       Icon(FluentIcons.person_16_regular),
                        Text('Users',style: TextStyle(fontSize: 17,),)
                    ],
                  ),
                ))
                , Container(height: 40,
                  child: Center(
                  child: Row(
                    children: [
                      Icon(FluentIcons.number_symbol_24_regular),
                      Text('tags',style: TextStyle(fontSize: 17,),)
                    ],
                  ),)
                )
              ],
            ),
        leading: 
            Container(
              margin: EdgeInsets.all(6),
              width: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
              ),
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
              maxLength: 100,
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(fontSize: 18),
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                counterText: '',
                hintStyle: TextStyle(
                  color: Theme.of(context).iconTheme.color.withOpacity(0.8),
                ),
                fillColor: Theme.of(context).cardColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    width: 0,
                    color: Theme.of(context).cardColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    width: 0,
                    color: Theme.of(context).cardColor,
                  ),
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
              onFieldSubmitted: (search) {
                  handleSearch(search);
              },
            ),
          ),
        ),
      ),
    );
  }
   getPosts(){

   }
   getUsers(){


   }
   getTags(){

   }
  @override
  void initState() {
    getRecentSearches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
          child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: buildSearchField(context),
        body: !searching
            ? (loading
                ? circularProgress()
                : Column(
                    children: [
                      Container(height: 400, child: recentSearchesWidget),
                      Expanded(
                          child: Container(
                              // color: Theme.of(context).canvasColor,
                              // child: Center(
                              //     child: Icon(
                              //   FluentIcons.search_28_filled,
                              //   color: Colors.grey,
                              //   size: 80,
                              // ))
                              )
                          // emptyState(context, "Search something new!", 'Searching')
                          )
                    ],
                  ))
            : TabBarView(children: <Widget>[
              ListView.builder(itemBuilder: (context,i){
                return Container();
              }),
             ListView.builder(itemBuilder: (context,i){
                return Container();
              }),
              ListView.builder(itemBuilder: (context,i){
                return Container();
              }),
            ],),
      ),
    );
  }
}
