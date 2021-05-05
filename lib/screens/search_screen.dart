// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import '../widgets/post.dart';
import 'package:blue/main.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/progress.dart';
import './home.dart';
import './search_results_screen.dart';
import '../services/hasura.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../services/preferences_update.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  QuerySnapshot searches;
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> peopleResultsFuture;
  Future<QuerySnapshot> postsResultsFuture;
  bool recentSearchesLoading = false;
  Widget recentSearchesWidget;
  bool searching = false;
  bool resultsLoading = true;
  String search;
  handleSearch(String query) async {
    setState(() {
      if (!searching) {
        searching = true;
        search = searchController.text;
      }
    });
    Hasura.insertSearch(query);
  }

  List<Widget> posts = [];
  List<Widget> userTiles = [];
  List<Widget> tags = [];

  bool loading = true;

  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => searchController.clear());
  }

  PreferredSize buildSearchField(context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(searching ? 95.0 : 50),
      child: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        bottom: !searching
            ? PreferredSize(
                child: Container(),
                preferredSize: Size.fromHeight(0),
              )
            : TabBar(
                indicatorColor: Colors.deepOrange,
                indicatorPadding:
                    EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                indicatorWeight: 2.0,
                tabs: [
                  Container(
                    height: 45,
                    child: Center(
                        child: Text(
                      'Top',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    )),
                  ),
                  Container(
                      height: 45,
                      child: Center(
                          child: Text(
                        'People',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ))),
                  Container(
                      height: 45,
                      child: Center(
                        child: Text(
                          'Tags',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ))
                ],
              ),
        leading: Container(
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
              onFieldSubmitted: (search) async {
                await handleSearch(search);
              },
            ),
          ),
        ),
      ),
    );
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
            ? RecentSearches()
            : TabBarView(
                children: <Widget>[
                  SearchResultsScreen(SearchResultsType.posts,
                      searchController.text, UniqueKey()),
                  SearchResultsScreen(SearchResultsType.people,
                      searchController.text, UniqueKey()),
                  SearchResultsScreen(SearchResultsType.tags,
                      searchController.text, UniqueKey())
                ],
              ),
      ),
    );
  }
}

class RecentSearches extends StatefulWidget {
  @override
  _RecentSearchesState createState() => _RecentSearchesState();
}

class _RecentSearchesState extends State<RecentSearches> {
  bool loading = true;
  dynamic _recentSearches;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    _recentSearches = await Hasura.getSearches(10);
    setState(() {
      loading = false;
    });
  }

  bool showClearAll = true;
  @override
  Widget build(BuildContext context) {
    if (_recentSearches.length == null) {
      showClearAll = false;
    } else {
      if (_recentSearches.length == 0) {
        showClearAll = false;
      }
    }
    return loading
        ? circularProgress()
        : !showClearAll
            ? emptyState(context, 'No Searches Yet.', 'none')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _recentSearches.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Container(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Searches',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 20),
                          ),
                          Material(
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () {
                                PreferencesUpdate().updateString(
                                  'searches_last_cleared',
                                  DateTime.now().toString(),
                                  upload: true,
                                ); //TODO  timezone problem
                                setState(() {
                                  _recentSearches = [];
                                });
                              },
                              child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    'Clear All',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  )),
                            ),
                          )
                        ],
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
                          setState(() {
                            _recentSearches.removeAt(index - 1);
                          });
                        });
                      },
                    ),
                  );
                });
  }
}
