// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Project imports:
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/progress.dart';

class SearchTagScreen extends StatefulWidget {
  static const routeName = 'search-tag';
  @override
  _SearchTagScreenState createState() => _SearchTagScreenState();
}

class _SearchTagScreenState extends State<SearchTagScreen> {
  TextEditingController tagSearchController = TextEditingController();
  String searchTerm = '';
  List tagResults = [];
  List tagStrings = [];
  bool loading = false;
  InkWell tagTile(String tag, int id) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, {id: tag});
      },
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5), child: Text('#$tag')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        leading: CupertinoNavigationBarBackButton(),
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(right: 20.0, left: 0),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            child: TextFormField(
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
              ],
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(
                fontSize: 18,
              ),
              onChanged: (value) async {
                //TODO fix
                String _searchTerm;
                setState(() {
                  searchTerm = value;
                  loading = true;
                  _searchTerm = searchTerm;
                });

                await Future.delayed(Duration(
                  seconds: 2,
                ));

                if (_searchTerm != searchTerm) {
                  return;
                }
                if (value == '') {
                  tagResults = [];
                } else {
                  Future future = Hasura.findTags(_searchTerm
                      .toLowerCase()
                      .replaceAll(new RegExp(r"\s+"), ""));
                  future.then((value) {
                    setState(() {
                      tagResults = value;
                      tagStrings = [];
                      tagResults.forEach((element) {
                        tagStrings.add(element['tag']);
                      });
                    });
                    loading = false;
                  });
                }
                // setState(() {
                //   loading = false;
                // });
              },
              controller: tagSearchController,
              decoration: InputDecoration(
                hintText: 'Search Tags',
                hintStyle: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).iconTheme.color.withOpacity(0.8)),
                fillColor: Theme.of(context).cardColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(
                      width: 0, color: Theme.of(context).backgroundColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(
                      width: 0, color: Theme.of(context).backgroundColor),
                ),
                prefixIcon: Icon(
                  FlutterIcons.search_oct,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              onFieldSubmitted: null,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (searchTerm != '' &&
                (!tagStrings
                    .contains(tagSearchController.text.trim().toLowerCase())))
              Material(
                  child: InkWell(
                onTap: () async {
                  if (loading == true) {
                    return;
                  }
                  int id = await Hasura.createTag(tagSearchController.text
                      .replaceAll(new RegExp(r"\s+"), ""));
                  Navigator.of(context).pop({id: searchTerm});
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              searchTerm == null
                                  ? ''
                                  : '#${searchTerm.toLowerCase().replaceAll(new RegExp(r"\s+"), "")}',
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          '+Create',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            if (loading && searchTerm != '')
              Center(
                child: circularProgress(),
              ),
            if (searchTerm != '' && !loading)
              Expanded(
                child: Material(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pop(
                              {tagResults[i]['tag_id']: tagResults[i]['tag']});
                        },
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text(
                                  tagResults[i]['tag'],
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600),
                                ),
                                // Text(
                                //   tagResults[i]['label'],
                                //   style: TextStyle(
                                //       fontSize: 22,
                                //       fontWeight: FontWeight.w600),
                                // ),
                                Text(
                                  '${tagResults[i]['postCount']} Posts',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            )),
                      );
                    },
                    itemCount: tagResults.length,
                  ),
                ),
              ),
            if (searchTerm == '')
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                alignment: Alignment.bottomCenter,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Icon(
                        FluentIcons.number_symbol_24_filled,
                        size: 26,
                      ),
                    ),
                    Icon(
                      FluentIcons.search_24_regular,
                      size: 80,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
