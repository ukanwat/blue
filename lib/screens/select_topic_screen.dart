// Flutter imports:
import 'package:blue/screens/explore_screen.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/search_tag_screen.dart';
import 'package:blue/widgets/progress.dart';
import 'home.dart';

class SelectTopicScreen extends StatefulWidget {
  static const routeName = 'select-topic';

  @override
  _SelectTopicScreenState createState() => _SelectTopicScreenState();
}

class _SelectTopicScreenState extends State<SelectTopicScreen> {
  String contentCategoryValue;
  bool isSwitched = false;
  bool isLoading = true;
  int noOfFollowedTopicListTiles;
  bool topicSelected = false;
  bool postSubmitting = false;
  List<Widget> tagChips = [];
  Map<int, String> tags = {};
  List topics;
  @override
  void initState() {
    getTopics();
    super.initState();
  }

  addTag() async {
    Navigator.of(context).pushNamed(SearchTagScreen.routeName).then((obj) {
      Map doc = obj;
      if (doc == null) {
        return;
      }
      int key = doc.keys.first;
      String value = doc.values.first;
      print(doc);
      if (value != null && !tags.containsKey(key))
        setState(() {
          tags[key] = value;
          tagChips.add(Chip(
            deleteIcon: Icon(
              FluentIcons.delete_24_regular,
              size: 16,
            ),
            onDeleted: () {
              tags.remove(key);
              setState(() {
                tagChips.removeAt(tagChips.length - 1);
              });
            },
            label: Text(
              value.toLowerCase().replaceAll(new RegExp(r"\s+"), ""),
              style: TextStyle(
                  color: Theme.of(context).iconTheme.color.withOpacity(0.8)),
            ),
          ));
        });
    });
  }

  getTopics() async {
    topics = [
      'Humor',
      'Art & Design',
      'Tech & Science',
      'News',
      'Entertainment',
      'Lifestyle',
      'Other'
    ];

    setState(() {
      isLoading = false;
      noOfFollowedTopicListTiles = topics.length;
    });
  }

  String selectedTopicTile;
  @override
  Widget build(BuildContext context) {
    final postData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(
            'Post Settings',
            style: TextStyle(),
          ),
          leading: IconButton(
            icon: Icon(FlutterIcons.ios_arrow_back_ion,
                size: 30, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.grey,
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                if (selectedTopicTile != null) {
                  setState(() {
                    showDialog(
                        barrierDismissible: false,
                        // useRootNavigator: false,
                        context: context,
                        builder: (BuildContext context) => WillPopScope(
                              onWillPop: () async {
                                return false;
                              },
                              child: Dialog(
                                insetPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width / 2 -
                                            64),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0.0,
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 12),
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10.0,
                                        offset: const Offset(0.0, 10.0),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: Icon(
                                          FluentIcons.arrow_circle_up_24_filled,
                                          size: 40,
                                        ),
                                      ),
                                      Container(
                                        height: 4,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                140,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: LinearProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.blue),
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Submitting',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ));
                  });

                  postData['post-function'](selectedTopicTile, tags);
                }
              },
              child: Text(
                'Post',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: selectedTopicTile == null
                        ? Colors.grey
                        : Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 8,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                Text(
                  'TAGS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 8,
                ),
                GestureDetector(
                  onTap: () {
                    addTag();
                  },
                  child: Container(
                      height: 26,
                      width: 86,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5)),
                      child: Center(
                        child: Text(
                          'Add Tag',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )),
                ),
              ],
            ),
            if (tagChips.length > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 6,
                  children: tagChips,
                ),
              )
            else
              Container(
                height: 120,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 50, bottom: 5, top: 5),
                      child: Icon(
                        FluentIcons.number_symbol_square_20_regular,
                        size: 55,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 10,
            ),
            Divider(
              color: Colors.grey,
              height: 0.3,
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Text(
                    'SELECT CATEGORY',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    FluentIcons.chevron_right_12_filled,
                    color: Colors.blue,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            isLoading
                ? circularProgress()
                : ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (_, i) {
                      return ListTile(
                        enabled: true,
                        dense: true,
                        title: Text(
                          topics[i],
                          style: TextStyle(fontSize: 20),
                        ),
                        trailing: selectedTopicTile == topics[i]
                            ? Icon(
                                Icons.check,
                                color: Colors.blue,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            if (selectedTopicTile == topics[i]) {
                              selectedTopicTile = null;
                            } else {
                              selectedTopicTile = topics[i];
                            }
                          });
                        },
                      );
                    },
                    itemCount: topics.length,
                  )
          ],
        ),
      ),
    );
  }
}
