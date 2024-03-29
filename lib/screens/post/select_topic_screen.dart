// Flutter imports:
import 'package:blue/widgets/button.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:blue/constants/app_colors.dart';
// Package imports:

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/explore_screen.dart';
import 'package:blue/screens/post/search_tag_screen.dart';
import 'package:blue/widgets/progress.dart';

//TODO:imp always save and set state for new thing/settings on this screen
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
  Map<String, dynamic> postData;
  @override
  void didChangeDependencies() {
    postData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    state = postData['state'];
    tags = state['tags'] ?? {};
    tags.forEach((key, value) {
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
    explicit = state['explicit'] ?? false;
    selectedTopicTile = state['selectedTopicTile'];
    super.didChangeDependencies();
  }

  @override
  void initState() {
    getTopics();
    super.initState();
  }

  Map state = {};
  bool explicit = false;

  addTag() async {
    Navigator.of(context).pushNamed(SearchTagScreen.routeName).then((obj) {
      Map doc = obj;
      if (doc == null) {
        return;
      }
      int key = doc.keys.first;
      String value = doc.values.first;
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
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          elevation: 0.5,
          centerTitle: true,
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(
            'Post Settings',
            style: TextStyle(
                fontWeight: FontWeight.w600, fontFamily: 'Stark Sans'),
          ),
          leading: BoxButton(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Icon(FluentIcons.chevron_left_12_filled,
                  size: 24, color: Theme.of(context).primaryColor),
            ),
            () {
              Navigator.pop(context, {
                'selectedTopicTile': selectedTopicTile,
                'tags': tags,
                'explicit': explicit
              });
            },
            margin: 8,
          ),

          // IconButton(
          //   icon: Icon(FlutterIcons.ios_arrow_back_ion,
          //       size: 30, color: Theme.of(context).primaryColor),
          //   onPressed: () {
          //     Navigator.pop(context, {
          //       'selectedTopicTile': selectedTopicTile,
          //       'tags': tags,
          //       'explicit': explicit
          //     });
          //   },
          //   color: Colors.grey,
          // ),
          actions: <Widget>[
            BoxButton(
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
              ),
              () {
                if (selectedTopicTile != null) {
                  setState(() {
                    showDialog(
                        barrierDismissible: !kReleaseMode,
                        // useRootNavigator: false,
                        context: context,
                        builder: (BuildContext context) => WillPopScope(
                              onWillPop: () async {
                                return !kReleaseMode;
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
                                                  AppColors.blue),
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

                  postData['post-function'](selectedTopicTile, tags, explicit);
                } else
                  snackbar('Select a category', context);
              },
              margin: 8,
            )
            // FlatButton(
            //   onPressed: () {
            //     if (selectedTopicTile != null) {
            //       setState(() {
            //         showDialog(
            //             barrierDismissible: !kReleaseMode,
            //             // useRootNavigator: false,
            //             context: context,
            //             builder: (BuildContext context) => WillPopScope(
            //                   onWillPop: () async {
            //                     return !kReleaseMode;
            //                   },
            //                   child: Dialog(
            //                     insetPadding: EdgeInsets.symmetric(
            //                         horizontal:
            //                             MediaQuery.of(context).size.width / 2 -
            //                                 64),
            //                     shape: RoundedRectangleBorder(
            //                       borderRadius: BorderRadius.circular(15),
            //                     ),
            //                     elevation: 0.0,
            //                     backgroundColor: Colors.transparent,
            //                     child: Container(
            //                       padding: EdgeInsets.symmetric(
            //                           vertical: 18, horizontal: 12),
            //                       decoration: new BoxDecoration(
            //                         color: Theme.of(context).canvasColor,
            //                         shape: BoxShape.rectangle,
            //                         borderRadius: BorderRadius.circular(15),
            //                         boxShadow: [
            //                           BoxShadow(
            //                             color: Colors.black26,
            //                             blurRadius: 10.0,
            //                             offset: const Offset(0.0, 10.0),
            //                           ),
            //                         ],
            //                       ),
            //                       child: Column(
            //                         mainAxisSize: MainAxisSize.min,
            //                         children: <Widget>[
            //                           Padding(
            //                             padding:
            //                                 const EdgeInsets.only(bottom: 16),
            //                             child: Icon(
            //                               FluentIcons.arrow_circle_up_24_filled,
            //                               size: 40,
            //                             ),
            //                           ),
            //                           Container(
            //                             height: 4,
            //                             width:
            //                                 MediaQuery.of(context).size.width -
            //                                     140,
            //                             decoration: BoxDecoration(
            //                                 borderRadius:
            //                                     BorderRadius.circular(10)),
            //                             child: LinearProgressIndicator(
            //                               valueColor:
            //                                   AlwaysStoppedAnimation<Color>(
            //                                       AppColors.blue),
            //                               backgroundColor: Colors.transparent,
            //                             ),
            //                           ),
            //                           SizedBox(height: 10),
            //                           Text(
            //                             'Submitting',
            //                             style: TextStyle(
            //                                 fontWeight: FontWeight.w600,
            //                                 fontSize: 13),
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   ),
            //                 ));
            //       });

            //       postData['post-function'](selectedTopicTile, tags, explicit);
            //     }
            //   },
            //   child: Text(
            //     'Post',
            //     style: TextStyle(
            //         fontSize: 20,
            //         fontWeight: FontWeight.w600,
            //         color: selectedTopicTile == null
            //             ? Colors.grey
            //             : Theme.of(context).primaryColor),
            //   ),
            // ),
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
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).canvasColor),
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        'TAGS',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            addTag();
                          },
                          child: Container(
                              height: 26,
                              width: 86,
                              decoration: BoxDecoration(
                                  color: AppColors.blue,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text(
                                  'Add Tag',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              )),
                        ),
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
                            padding: const EdgeInsets.only(
                                left: 50, bottom: 5, top: 5),
                            child: Icon(
                              FluentIcons.number_symbol_square_20_regular,
                              size: 55,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).canvasColor),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Text(
                        'SELECT CATEGORY',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        FluentIcons.chevron_right_12_filled,
                        color: AppColors.blue,
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
                        physics: NeverScrollableScrollPhysics(),
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
                                    color: AppColors.blue,
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
              ]),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).canvasColor),
                child: settingsSwitchListTile(
                    'Contains Explicit Content', explicit, (newValue) {
                  setState(() {
                    explicit = newValue;
                  });
                }))
          ],
        ),
      ),
    );
  }
}
