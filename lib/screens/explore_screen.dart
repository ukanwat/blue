// Flutter imports:
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/bottom_sheet.dart';
import 'package:blue/widgets/dialogs/empty_dialog.dart';
import 'package:flutter/material.dart';

// Package imports:

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import 'package:blue/screens/explore/category_posts_screen.dart';
import 'package:blue/screens/search_screen.dart';
import 'package:blue/widgets/post.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/tags_wrap.dart';
import 'package:get/get.dart';
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
  showTagsSheet() {
    showSheet(
      context,
      TagsWrap(),
      Material(
        child: Container(
          height: 54,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Text('Tags You Follow',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    )),
              ),
              Expanded(
                child: Container(),
              ),
              IconButton(
                  icon: Icon(Icons.keyboard_arrow_down,
                      size: 28, color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget tabView;
  List<Tab> topicTabs = [
    Tab(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('Everything',
          style: TextStyle(
              fontFamily: 'Stark Sans',
              fontWeight: FontWeight.w800,
              fontSize: 17)),
    ))
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
  reorder(Function re) {
    print('reorder!');
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
                                fontWeight: FontWeight.w800,
                                fontSize: 17)))
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
                  PreferencesUpdate()
                      .uploadValue('tabs', tJson, false, update: true);
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
            onReorder: re,
            onNoReorder: (int index) {
              //this callback is optional
              debugPrint(
                  '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
            },
          ));
        });
  }

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

  List _rows = [];

  getTopics() async {
    t.forEach((topic) {
      topicTabs.add(Tab(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(topic,
                  style: TextStyle(
                      fontFamily: 'Stark Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 17)))));
    });
    setState(() {
      tabController = new TabController(length: t.length + 2, vsync: this);
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(42),
          child: AppBar(
            automaticallyImplyLeading: false,
            brightness: Theme.of(context).brightness,
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 0,
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'EXPLORE',
                style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Techna Sans Regular',
                    color: Theme.of(context).iconTheme.color),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(
                    FluentIcons.add_24_regular,
                    size: 27,
                  ),
                  onPressed: () {
                    showTagsSheet();
                  },
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Hero(
              tag: 'search_bar',
              child: Material(
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      SearchScreen.routeName,
                    );
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width - 30,
                      height: 35,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).cardColor),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                FlutterIcons.search_oct,
                                size: 22,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Search',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      .withOpacity(0.8),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                      // child: TextFormField(
                      //   readOnly: true,
                      //   textAlignVertical: TextAlignVertical.bottom,
                      //   style: TextStyle(fontSize: 18),
                      //   decoration: InputDecoration(
                      //     hintText: 'Search',
                      //     counterText: '',
                      //     hintStyle: TextStyle(
                      //       color: Theme.of(context)
                      //           .iconTheme
                      //           .color
                      //           .withOpacity(0.8),
                      //     ),
                      //     fillColor: Theme.of(context).cardColor,
                      //     filled: true,
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(15),
                      //       borderSide: BorderSide(
                      //         width: 0,
                      //         color: Theme.of(context).cardColor,
                      //       ),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(15),
                      //       borderSide: BorderSide(
                      //         width: 0,
                      //         color: Theme.of(context).cardColor,
                      //       ),
                      //     ),
                      //     prefixIcon: Icon(
                      //       FlutterIcons.search_oct,
                      //       size: 22,
                      //       color: Colors.grey,
                      //     ),
                      //   ),
                      // ),

                      ),
                ),
              ),
            ),
            loading
                ? Container(
                    height: 35,
                    color: Theme.of(context).backgroundColor,
                  )
                : Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                    ),
                    padding:
                        EdgeInsets.only(left: 8, right: 8, bottom: 0, top: 2),
                    child: TabBar(
                        onTap: (i) {
                          if (i != t.length + 1) {
                            setState(() {
                              index = i - 1;
                            });
                          } else {
                            reorder(_onReorder);
                          }
                        },
                        indicatorColor: Theme.of(context).iconTheme.color,
                        indicatorWeight: 2,
                        isScrollable: true,
                        labelPadding: EdgeInsets.only(
                            left: 5, right: 5, bottom: 0, top: 0),
                        indicatorSize: TabBarIndicatorSize.label,
                        controller: tabController,
                        labelColor: Theme.of(context).iconTheme.color,
                        unselectedLabelColor:
                            Theme.of(context).iconTheme.color.withOpacity(0.5),
                        // unselectedLabelColor: Theme.of(context).iconTheme.color,
                        // labelPadding:
                        //     EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        tabs: topicTabs +
                            [
                              Tab(
                                child: GestureDetector(
                                    onTap: () {
                                      reorder(_onReorder);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Icon(
                                        FluentIcons
                                            .re_order_dots_horizontal_16_filled,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                    )),
                              ),
                            ]),
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
