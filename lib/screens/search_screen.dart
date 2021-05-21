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
      preferredSize: Size.fromHeight(searching ? 90.0 : 50),
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
                indicatorWeight: 2.0,
                tabs: [
                  Container(
                    height: 40,
                    child: Center(
                        child: Text(
                      'Top',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    )),
                  ),
                  Container(
                      height: 40,
                      child: Center(
                          child: Text(
                        'People',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ))),
                  Container(
                      height: 40,
                      child: Center(
                        child: Text(
                          'Tags',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
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
                FluentIcons.chevron_left_24_filled,
                color: Colors.blue,
                size: 22,
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

  onSearch(String term) {
    searchController.text = term;
    handleSearch(term);
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
            ? RecentSearches(onSearch)
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
  final ValueChanged<String> callback;

  RecentSearches(this.callback);
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
    _recentSearches = await Hasura.getSearches(5);
    print(_recentSearches);
    setState(() {
      loading = false;
    });
  }

  bool showClearAll = true;
  @override
  Widget build(BuildContext context) {
    if (_recentSearches == null) {
      showClearAll = false;
    } else if (_recentSearches.length == 0) {
      showClearAll = false;
    } else {
      showClearAll = true;
    }

    return loading
        ? Center(child: circularProgress())
        : !showClearAll
            ? emptyState(context, 'No Searches Yet.', 'none')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _recentSearches.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.3)))),
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 25, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Searches',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 20),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  )),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                  return Column(children: [
                    ListTile(
                      dense: true,
                      leading: Icon(FluentIcons.search_16_filled),
                      key: UniqueKey(),
                      title: Text(
                        _recentSearches[index - 1]['text'],
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.blue),
                      ),
                      onTap: () {
                        widget.callback(_recentSearches[index - 1]['text']);
                      },
                      trailing: IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 20,
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
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 40,
                    )
                  ]);
                });
  }
}
