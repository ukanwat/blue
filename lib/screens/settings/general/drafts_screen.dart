// Flutter imports:
import 'dart:io';

import 'package:blue/screens/post_screen.dart';
import 'package:blue/services/link_preview.dart';
import 'package:blue/services/video_controls.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// Project imports:
import 'package:blue/services/boxes.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:blue/widgets/show_dialog.dart';

class DraftsScreen extends StatefulWidget {
  static const routeName = 'drafts';
  @override
  _DraftsScreenState createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  List contentsData = [];
  @override
  void initState() {
    // draftBox.keys.forEach((key) { draftBox.delete(key);});
    contentsData =  Boxes.draftBox.values.toList();
    print('drafts - $contentsData');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: settingsHeader(context, 'Drafts'),
      body: ListView.builder(
        itemCount: contentsData.length,
        itemBuilder: (_, i) {
          List post = contentsData[i]['contentsData'];
          print('draft data $post');
          List<Widget> widgets = [];
          post.forEach((element) {
            switch (element['info']['type']) {
              case 'text':
                widgets.add(Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    element['content'],
                    style: TextStyle(fontSize: 17, height: 1.3),
                  ),
                ));
                break;

              case 'image':
                widgets.add(Image.file(File(element['content'])));
                break;
              case 'carousel':
                widgets.add(Carousel(
                  dotVerticalPadding: 0,
                  dotSize: 6,
                  dotIncreaseSize: 1.2,
                  dotIncreasedColor: Colors.blue.withOpacity(0.7),
                  dotColor: Colors.white,
                  showIndicator: true,
                  dotPosition: DotPosition.bottomCenter,
                  dotSpacing: 15,
                  boxFit: BoxFit.fitWidth,
                  dotBgColor: Colors.transparent,
                  autoplay: false,
                  overlayShadow: false,
                  moveIndicatorFromBottom: 20,
                  images: List.generate(element['content'].length, (j) {
                    return FileImage(File(element['content'][j]));
                  }),
                ));
                break;
              case 'link':
                widgets.add(Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Theme.of(context).canvasColor),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinkPreview(
                          url: element['content'],
                          bodyStyle: TextStyle(fontSize: 13),
                          titleStyle: TextStyle(fontWeight: FontWeight.w500),
                          showMultimedia: true,
                        ))));
                break;

              case 'video':
                FlickManager flickManager;
                VideoPlayerController _videoPlayerController;
                _videoPlayerController =
                    VideoPlayerController.file(File(element['content']))
                      ..initialize().then((_) {
                        flickManager = FlickManager(
                          videoPlayerController: _videoPlayerController,autoPlay: false,autoInitialize: true
                        );
                      });
                widgets.add(VideoDisplay(flickManager, false));
                break; //TODO check for video

            }
          });

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).canvasColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    contentsData[i]['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),
                  padding: EdgeInsets.all(10),
                ),
                ...widgets,
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: ClipRRect(
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(10)),
                      child: Material(
                        child: InkWell(
                          onTap: () {
                            showDialog(context: context,builder: (context){
                                 return ShowDialog(title: 'Delete Draft',description: 'Are you sure you want to delete this draft?',leftButtonText: 'Cancel',rightButtonText: 'Delete',rightButtonFunction: ()async{
                                
                                   setState(() {
                                     Boxes.draftBox.deleteAt(i);
                                    contentsData.removeAt(i);
                                   
                                   });
                                   Navigator.of(context).pop();
                                   
                                    final Directory _appDocDir = await getApplicationDocumentsDirectory();
                                       Directory(_appDocDir.path+'/posts/${contentsData[i]['postId']}').deleteSync(recursive: true);

                                 },);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 11),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FluentIcons.delete_20_filled,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  Text(
                                    'Delete',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                    Container(
                      height: 40,
                      width: 1,
                      color: Theme.of(context).cardColor,
                    ),
                    Expanded(
                        child: ClipRRect(
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(10)),
                      child: Material(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(PostScreen.routeName,arguments: i);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FluentIcons.drafts_20_filled,
                                    size: 20,
                                  ),
                                  Text(
                                    'Edit',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                )
              ],
              mainAxisSize: MainAxisSize.min,
            ),
          );
        },
      ),
    );
  }
}
