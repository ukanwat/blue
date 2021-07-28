// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import 'package:blue/constants/app_colors.dart';
import 'package:blue/main.dart';
import 'package:blue/widgets/empty_state.dart';
import 'package:blue/widgets/progress.dart';
import '../services/hasura.dart';
import '../services/preferences_update.dart';
import '../widgets/post.dart';
import 'search/search_results_screen.dart';

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
                indicatorColor: Theme.of(context).accentColor,
                indicatorWeight: 2.0,
                tabs: [
                  Container(
                    height: 40,
                    child: Center(
                        child: Text(
                      'Top',
                      style: TextStyle(
                        fontFamily: "Stark Sans",
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    )),
                  ),
                  Container(
                      height: 40,
                      child: Center(
                          child: Text(
                        'People',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Stark Sans",
                          fontWeight: FontWeight.w800,
                        ),
                      ))),
                  Container(
                      height: 40,
                      child: Center(
                        child: Text(
                          'Tags',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "Stark Sans",
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ))
                ],
              ),
        leading: GestureDetector(
            child: Icon(
              FluentIcons.chevron_left_16_filled,
              color: Colors.blue,
              size: 30,
            ),
            onTap: () {
              Navigator.pop(context);
            }),
        leadingWidth: 30,
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
    _recentSearches = await Hasura.getSearches(8);
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
                itemCount: _recentSearches.length + 2,
                itemBuilder: (BuildContext context, int index) {
                  if (_recentSearches.length + 1 == index) {
                    return Container();
                  }
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
                                fontFamily: 'Stark Sans',
                                fontWeight: FontWeight.w800,
                                fontSize: 22),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Material(
                              borderRadius: BorderRadius.circular(80),
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
                                  child: Row(
                                    children: [
                                      // Text(
                                      //   'Clear All',
                                      //   style: TextStyle(
                                      //       color: Theme.of(context)
                                      //           .iconTheme
                                      //           .color
                                      //           .withOpacity(0.7),
                                      //       fontSize: 14,
                                      //       fontWeight: FontWeight.w700),
                                      // ),
                                      // SizedBox(
                                      //   width: 5,
                                      // ),
                                      Icon(FluentIcons.delete_16_filled,
                                          size: 18,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(children: [
                    ListTile(
                      dense: true,
                      leading: Icon(FluentIcons.arrow_circle_up_left_24_regular,
                          size: 26,
                          color: Color.fromRGBO(
                              50 +
                                  (((index + 1) * 160) ~/
                                      _recentSearches.length),
                              60 +
                                  (((index + 1) * 100) ~/
                                      _recentSearches.length),
                              230 +
                                  (((index + 1) * 10) ~/
                                      _recentSearches.length),
                              1)),
                      key: UniqueKey(),
                      title: Text(
                        _recentSearches[index - 1]['text'],
                        style: TextStyle(
                          fontFamily: 'Stark Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                        ),
                      ),
                      onTap: () {
                        widget.callback(_recentSearches[index - 1]['text']);
                      },
                      trailing: IconButton(
                        icon: Icon(
                          FluentIcons.block_16_regular,
                          size: 22,
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
                      color: Colors.grey.withOpacity(0.3),
                      thickness: 1,
                    )
                  ]);
                });
  }
}
