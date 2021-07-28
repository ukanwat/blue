// Flutter imports:
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/dialogs/empty_dialog.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import 'package:blue/screens/explore/category_posts_screen.dart';
import 'package:blue/screens/search_screen.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/tags_wrap.dart';
import 'package:reorderables/reorderables.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with
        AutomaticKeepAliveClientMixin<ExploreScreen>,
        TickerProviderStateMixin {
  List<Post> posts = [];

  Widget tabView;
  List<Tab> topicTabs = [
    Tab(
        child: Text('Everything',
            style: TextStyle(
              fontFamily: 'Stark Sans',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            )))
  ];
  bool loading = true;
  TabController tabController;
  List<String> t = [
    'Humor',
    'Art & Design',
    'Tech & Science',
    'News',
    'Entertainment',
    'Lifestyle'
  ];
  int index;
  List<String> _t;
  @override
  void initState() {
    List<dynamic> json = PreferencesUpdate().getValue('tabs');
    print(json);
    if (json != null && json != []) {
      t = [];
      int _i = 0;

      json.forEach((element) {
        t.add(element['$_i']);
        _i++;
      });
    }

    _rows = List<ReorderableWidget>.generate(
        t.length,
        (int index) => ReorderableWidget(
              reorderable: true,
              key: ValueKey(index),
              child: Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          t[index],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Stark Sans'),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Icon(FluentIcons.re_order_16_filled)
                      ],
                    )),
              ),
            ));

    getTopics();
    tabView = CategoryPostsScreen('All', UniqueKey());
    super.initState();
  }

  showTagsSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        builder: (context) => TagsWrap());
  }

  List _rows = [];

  getTopics() async {
    t.forEach((topic) {
      topicTabs.add(Tab(
          child: Text(topic,
              style: TextStyle(
                  fontFamily: 'Stark Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16))));
    });
    setState(() {
      tabController = new TabController(length: t.length + 1, vsync: this);
      loading = false;
    });
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Widget row = _rows.removeAt(oldIndex);
        String result = _t.removeAt(oldIndex);
        _t.insert(newIndex, result);
        _rows.insert(newIndex, row);
      });

      t = _t;
      topicTabs = [
        Tab(
            child: Text('Everything',
                style: TextStyle(
                  fontFamily: 'Stark Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                )))
      ];
      getTopics();
      index = -1;
    }

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          brightness: Theme.of(context).brightness,
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
          title: Text(
            'Explore',
            style: TextStyle(
              fontFamily: 'Techna Sans Regular',
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _t = t;
                  showDialog(
                      context: context,
                      builder: (context) {
                        return EmptyDialog(ReorderableColumn(
                          footer: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                t = _t;
                                topicTabs = [
                                  Tab(
                                      child: Text('Everything',
                                          style: TextStyle(
                                            fontFamily: 'Stark Sans',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          )))
                                ];
                                getTopics();
                                setState(() {
                                  index = -1;
                                });
                                List<Map> tJson = [];
                                int i = 0;
                                t.forEach((element) {
                                  tJson.add({'$i': t[i]});
                                  i++;
                                });
                                PreferencesUpdate().uploadValue(
                                    'tabs', tJson, false,
                                    update: true);
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text('Save',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Stark Sans')),
                                ),
                              ),
                            ),
                          ),
                          header: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'REORDER TABS',
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Theme.of(context).accentColor,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              Expanded(child: Container()),
                            ],
                          ),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _rows,
                          onReorder: _onReorder,
                          onNoReorder: (int index) {
                            //this callback is optional
                            debugPrint(
                                '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
                          },
                        ));
                      });
                },
                icon: Icon(
                  FluentIcons.re_order_dots_horizontal_16_filled,
                  color: Theme.of(context).iconTheme.color,
                ))
          ],
          leading: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
                icon: Icon(
                  FlutterIcons.search_oct,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(SearchScreen.routeName);
                },
                color: Theme.of(context).iconTheme.color),
          ),
        ),
        body: Column(
          children: [
            loading
                ? Container(
                    height: 0,
                    color: Theme.of(context).backgroundColor,
                  )
                : Container(
                    color: Theme.of(context).backgroundColor,
                    height: 40,
                    padding:
                        EdgeInsets.only(left: 8, right: 8, bottom: 0, top: 0),
                    child: TabBar(
                      onTap: (i) {
                        setState(() {
                          index = i - 1;
                        });
                      },
                      indicatorWeight: 2.5,
                      indicatorPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      isScrollable: true,
                      controller: tabController,
                      indicatorColor: Theme.of(context).accentColor,
                      // labelPadding:
                      //     EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      tabs: topicTabs,
                    ),
                  ),
            Expanded(
              child: CategoryPostsScreen(
                  index == null || index == -1 ? 'All' : t[index],
                  ValueKey(index == null || index == -1 ? 'All' : t[index])),
            ),
          ],
        ));
  }
}
