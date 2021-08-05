// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/constants/app_colors.dart';
// Package imports:
import 'package:flutter_clipboard_manager/flutter_clipboard_manager.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:blue/packages/giphy_client/giphy_client.dart';
import 'package:blue/packages/giphy_client/models/collection.dart';
import 'package:blue/widgets/progress.dart';

class GIFsScreen extends StatefulWidget {
  static const routeName = 'gifs';
  @override
  _GIFsScreenState createState() => _GIFsScreenState();
}

class _GIFsScreenState extends State<GIFsScreen> {
  GiphyCollection gifCollection;
  bool loading = false;
  final client = new GiphyClient(apiKey: null);
  TextEditingController gifSearchController = TextEditingController();
  @override
  void initState() {
    getTrendingGIFs();
    super.initState();
  }

  getTrendingGIFs() async {
    setState(() {
      loading = true;
    });
    gifCollection = await client.trending(
      limit: 20,
    );
    setState(() {
      loading = false;
    });
  }

  getSearchedGIFs(String searchTerm) async {
    setState(() {
      loading = true;
    });
    gifCollection = await client.search(gifSearchController.text, limit: 20);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
        leading: CupertinoNavigationBarBackButton(),
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(right: 20.0, left: 0),
          child: Container(
            height: 38,
            alignment: Alignment.center,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(fontSize: 18),
              controller: gifSearchController,
              decoration: InputDecoration(
                hintText: 'Search GIFs',
                hintStyle: TextStyle(
                    color: Theme.of(context).iconTheme.color.withOpacity(0.8)),
                fillColor: Theme.of(context).cardColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide:
                      BorderSide(width: 0, color: Theme.of(context).cardColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide:
                      BorderSide(width: 0, color: Theme.of(context).cardColor),
                ),
                prefixIcon: Icon(
                  FlutterIcons.search_fea,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              onFieldSubmitted: getSearchedGIFs,
            ),
          ),
        ),
      ),
      body: loading
          ? circularProgress()
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'Powered By',
                        style: TextStyle(fontSize: 12),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: Theme.of(context).iconTheme.color !=
                                    Colors.black
                                ? 8
                                : 4,
                            horizontal: 10),
                        height: 32,
                        child: Image.asset(Theme.of(context).iconTheme.color !=
                                Colors.black
                            ? 'assets/images/GIPHY_dark.png'
                            : 'assets/images/GIPHY_light.png'), //TODO check final icon color
                      ),
                    ],
                  ),
                  Container(
                    //  height: ((MediaQuery.of(context).size.width-16)/2 + 4)*25,
                    child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8),
                        itemCount: gifCollection.data.length,
                        itemBuilder: (_, i) {
                          return Container(
                            child: InkWell(
                              onLongPress: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) => Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        elevation: 0.0,
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5),
                                            decoration: new BoxDecoration(
                                              color:
                                                  Theme.of(context).canvasColor,
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 10.0,
                                                  offset:
                                                      const Offset(0.0, 10.0),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                if (gifCollection
                                                        .data[i].username !=
                                                    '')
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 5,
                                                        horizontal: 14),
                                                    child: Text('Created By'),
                                                  ),
                                                if (gifCollection
                                                        .data[i].username !=
                                                    '')
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      gifSearchController.text =
                                                          '@${gifCollection.data[i].username}';
                                                      getSearchedGIFs(
                                                          '@${gifCollection.data[i].username}');
                                                    },
                                                    child: Container(
                                                      margin:
                                                          EdgeInsetsDirectional
                                                              .only(
                                                                  bottom: 10,
                                                                  top: 0),
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 4),
                                                      child: Text(
                                                        '@${gifCollection.data[i].username}',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: AppColors.blue,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (gifCollection
                                                        .data[i].username !=
                                                    '')
                                                  Divider(
                                                    height: 10,
                                                    color: Colors.grey,
                                                  ),
                                                InkWell(
                                                  onTap: () async {
                                                    FlutterClipboardManager
                                                        .copyToClipBoard(
                                                            "${gifCollection.data[i].sourcePostUrl}");
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 12),
                                                    child: Center(
                                                        child: Text(
                                                      'Copy Source Link',
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    )),
                                                  ),
                                                )
                                              ],
                                            ))));
                              },
                              onTap: () {
                                Navigator.pop(context,
                                    gifCollection.data[i].images.original.url);
                              },
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width - 16) /
                                            2 -
                                        8,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).cardColor),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                      gifCollection
                                              .data[i].images.downsized.url ??
                                          gifCollection
                                              .data[i].images.original.url,
                                      height:
                                          (MediaQuery.of(context).size.width -
                                                      16) /
                                                  2 -
                                              8,
                                      fit: BoxFit.cover, loadingBuilder:
                                          (BuildContext ctx, Widget child,
                                              ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Shimmer.fromColors(
                                        baseColor: Theme.of(context).cardColor,
                                        highlightColor:
                                            Theme.of(context).canvasColor,
                                        child: Container(
                                          color: Colors.white,
                                          height: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      16) /
                                                  2 -
                                              8,
                                          width: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      16) /
                                                  2 -
                                              8,
                                        ),
                                      );
                                    }
                                  }),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
    );
  }
}
