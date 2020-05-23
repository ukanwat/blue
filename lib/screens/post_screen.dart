import 'package:blue/screens/select_topic_screen.dart';
import 'package:blue/widgets/custom_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import './home.dart';
import 'package:http/http.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/post_screen_common_widget.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';

enum ContentInsertOptions { Device, Camera }

class PostScreen extends StatefulWidget {
  static const routeName = '/post';
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Container> contents = [
    Container(),
  ];
  List<File> videos = [];
  List<File> images = [];
  List<String> texts = [];
  bool isImage = true; //TODO: check if the file is image file
  int fileIndex = 0;
  bool isUploading = false;
  VideoPlayerController _videoPlayerController;
  VideoPlayerController _cameraVideoPlayerController;
  var _videoCompress = FlutterVideoCompress();
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> textControllers = List();
  List<TextEditingController> linkControllers = List();
  Map<int, dynamic> contentsMap = {};
  Map<String, String> firestoreContents = {};
  Map<int, Map> contentsInfo = {};
  Map<String, Map> firestoreContentsInfo = {};
  List<String> contentType = [];
  String imageId = Uuid().v4();
  String videoId = Uuid().v4();
  String postId = Uuid().v4();
  File compressedFile;

// @override
// void dispose(){
//   _subscription.unsubscribe();
//   super.dispose();
// }
  handleTakePhoto() async {
    File _cameraImage;
    _cameraImage = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 960,
      maxWidth: 960,
    );
    fileIndex++;
    double aspectRatio;
    var decodedImage =
        await decodeImageFromList(_cameraImage.readAsBytesSync());
    aspectRatio =
        decodedImage.width.toDouble() / decodedImage.height.toDouble();
    Map infoMap = {};
    infoMap['type'] = 'image';
    infoMap['aspectRatio'] = aspectRatio;
    contentsInfo[fileIndex] = infoMap;
    setState(() {
      if (_cameraImage == null) {
        print('File is not available');
      } else {
        contents.add(imageDisplay(_cameraImage, fileIndex, aspectRatio));
      }
    });
    // compressImage(fileIndex);
  }

  handleTakeVideo() async {
    File _cameraVideo;
    _cameraVideo = await ImagePicker.pickVideo(source: ImageSource.camera);
    fileIndex++;
    _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo)
      ..initialize().then((_) {
        setState(() {
          contents.add(videoDisplay(
              _cameraVideo, _cameraVideoPlayerController, fileIndex));
          _cameraVideoPlayerController.play();
          if (_cameraVideoPlayerController.value.isPlaying == true) {
            print('amsdd');
          }
        });
      });
  }

  handleChooseVideoFromGallery() async {
    File _galleryVideo;
    _galleryVideo = await ImagePicker.pickVideo(source: ImageSource.gallery);
    fileIndex++;
    _videoPlayerController = VideoPlayerController.file(_galleryVideo)
      ..initialize().then((_) {
        setState(() {
          contents.add(
              videoDisplay(_galleryVideo, _videoPlayerController, fileIndex));
          _videoPlayerController.play();
          if (_videoPlayerController.value.isPlaying == true) {
            print('msdd');
          }
        });
      });
  }

  handleChooseImageFromGallery() async {
    File _galleryImage;
    _galleryImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    fileIndex++;
    double aspectRatio;
    var decodedImage =
        await decodeImageFromList(_galleryImage.readAsBytesSync());
    aspectRatio =
        decodedImage.width.toDouble() / decodedImage.height.toDouble();
    Map infoMap = {};
    infoMap['type'] = 'image';
    infoMap['aspectRatio'] = aspectRatio;
    contentsInfo[fileIndex] = infoMap;
    setState(() {
      contents.add(imageDisplay(_galleryImage, fileIndex, aspectRatio));
    });
    // compressImage(fileIndex);
  }

  Future<File> compressImage(File file) async {
    imageId = Uuid().v4();
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$imageId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    return compressedImageFile;
  }

  Future<MediaInfo> compressVideo(File file) async {
    final info = await _videoCompress.compressVideo(
      file.path,
      quality:
          VideoQuality.MediumQuality, // default(VideoQuality.DefaultQuality)
      deleteOrigin: false, // default(false)
    );
    return info;
  }

  Future<String> uploadImage(File file) async {
    StorageUploadTask uploadTask = storageRef
        .child("post_$imageId.jpg")
        .putFile(file, StorageMetadata(contentType: 'jpg'));
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadVideo(MediaInfo mediaInfo) async {
    StorageUploadTask uploadTask =
        storageRef.child('video_$videoId.mp4').putFile(mediaInfo.file);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({
    Map<String, String> contents,
    String title,
    Map<String, Map> contentsInfo,
    String topicName,
    String topicId,
  }) {
    postsRef
        .document(currentUser?.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': currentUser?.id,
      'username': currentUser?.username,
      'contents': contents,
      'contentsInfo': contentsInfo,
      'title': title,
      'timeStamp': timestamp,
      'upvotes': {},                     // TODO: Remove
      'topicId': topicId,
      'topicName': topicName
    }); // TODO: check if successful
    topicPostsRef
        .document(topicId)
        .collection('topicPosts')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': currentUser?.id,
      'username': currentUser?.username,
      'contents': contents,
      'contentsInfo': contentsInfo,
      'title': title,
      'timeStamp': timestamp,
      'upvotes': {},                          // TODO: Remove
      'topicId': topicId,
      'topicName': topicName,
    });
  }

  createPostInRealtimeDatabase(String topicId) {
    topicPostsDatabase.child('$topicId').child('$postId').set({
      'time': ServerValue.timestamp,
      'postId': postId,
      'ownerId': currentUser?.id,
      'upvotes': 0,
      'shared': 0,
      'comments': 0,
      'saves': 0,
      'follows': 0,
      'reports': 0,
      'views': 0,
    });
  }

  handleSubmit(String topicName, String topicId) async {
    setState(() {
      isUploading = true;
    });
    int x = 1;
    for (int i = 1; i <= contentsMap.length; i++) {
      if (contentType[i - 1] == 'null') {
      } else if (contentType[i - 1] == 'link') {
        firestoreContents['$x'] = contentsMap[i].text;
        firestoreContentsInfo['$x'] = contentsInfo[i];
        x++;
      } else if (contentType[i - 1] == 'text') {
        firestoreContents['$x'] = contentsMap[i].text;
        firestoreContentsInfo['$x'] = contentsInfo[i];
        x++;
      } else if (contentType[i - 1] == 'image') {
        File imageFile = await compressImage(contentsMap[i]);
        String mediaUrl = await uploadImage(imageFile);
        firestoreContents['$x'] = mediaUrl;
        firestoreContentsInfo['$x'] = contentsInfo[i];
        x++;
      } else if (contentType[i - 1] == 'video') {
        MediaInfo videoMediaInfo = await compressVideo(contentsMap[i]);
        String mediaUrl = await uploadVideo(videoMediaInfo);
        firestoreContents['$x'] = mediaUrl;
        firestoreContentsInfo['$x'] = contentsInfo[i];
        x++;
      }
    }

    await createPostInFirestore(
        contents: firestoreContents,
        title: titleController.text,
        contentsInfo: firestoreContentsInfo,
        topicName: topicName,
        topicId: topicId);
    await createPostInRealtimeDatabase(topicId);
    titleController.clear();
    textControllers = [];
    setState(() {
      isUploading = false;
      imageId = Uuid().v4();
      videoId = Uuid().v4();
      firestoreContents = {};
    });
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Container videoDisplay(
      File file, VideoPlayerController videoController, int index) {
    Map infoMap = {};
    infoMap['type'] = 'video';
    infoMap['aspectRatio'] = videoController.value.aspectRatio;
    contentsInfo[index] = infoMap;
    contentsMap[index] = file;
    contentType.add('video');
    return Container(
        child: Stack(alignment: Alignment.center, children: <Widget>[
      AspectRatio(
        aspectRatio: videoController.value.aspectRatio,
        child: VideoPlayer(videoController),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.black38, borderRadius: BorderRadius.circular(25)),
            child: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  contents.removeAt(index);
                });
              },
            )),
      ),
      Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: IconButton(
            icon: Icon(
              videoController.value.isPlaying ? null : Icons.play_arrow,
              color: Colors.white,
              size: 100,
            ),
            onPressed: () {
              setState(() {
                if (videoController.value.isPlaying)
                  videoController.pause();
                else
                  videoController.play();
              });
            },
          )),
    ]));
  }

  Container textDisplay(TextEditingController textController, int index) {
    Map infoMap = {};
    infoMap['type'] = 'text';
    contentsInfo[index] = infoMap;
    contentsMap[index] = textController;
    contentType.add('text');
    print(contentsMap);
    return Container(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: textController,
          decoration:
              InputDecoration(border: InputBorder.none, hintText: '...'),
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ));
  }

  Container linkDisplay(TextEditingController linkController, int index) {
    Map infoMap = {};
    infoMap['type'] = 'link';
    contentsInfo[index] = infoMap;
    contentsMap[index] = linkController;
    contentType.add('link');
    print(contentsMap);
    return Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      child: TextField(
        textAlign: TextAlign.center,
        controller: linkController,
        decoration: InputDecoration(
          hintText: 'Link',
          contentPadding: EdgeInsets.symmetric(horizontal: 3),
          prefixIcon: Icon(
            Icons.insert_link,
            color: Colors.grey,
          ),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 3,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey, width: 3),
          ),
        ),
        keyboardType: TextInputType.url,
        maxLines: 1,
        onSubmitted: verifyLink,
      ),
    );
  }

  void verifyLink(String linkText) async {
    final response = await head(linkText);
    if (response.statusCode == 200) {
      if (linkText.contains('.jpeg') ||
          linkText.contains('.jpg') ||
          linkText.contains('.png') ||
          linkText.contains('.gif') ||
          linkText.contains('.webp') || // TODO: test all formats
          linkText.contains('.jfif') ||
          linkText.endsWith('.bmp') ||
          linkText.contains('.tiff') ||
          linkText.contains('.svg')) {
        setState(() {
          contents.add(linkImageDisplay(linkText));
        });
      } else if (linkText.contains('.mp4') ||
          linkText.contains('.MOV') ||
          linkText.contains('.avi') ||
          linkText.contains('.wmv') ||
          linkText.contains('.webm') || // TODO: test all formats
          linkText.contains('.flv')) {
//             final uint8list = await VideoThumbnail.thumbnailFile(
//   video: linkText,
//   thumbnailPath: (await getTemporaryDirectory()).path,
//   imageFormat: ImageFormat.WEBP, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
//   quality: 75,
// );

      }
    }
  }

  Container linkImageDisplay(String link) {
    return Container(
      child: Stack(
          alignment: Alignment.center,
          children: <Widget>[(cachedNetworkImage(context, link))]),
    );
  }

  Container imageDisplay(File file, int index, double aspectRatio) {
    contentsMap[index] = file;
    contentType.add('image');
    return Container(
      key: ValueKey(index),
      child: Stack(alignment: Alignment.centerRight, children: <Widget>[
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(
                  file,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.black38, borderRadius: BorderRadius.circular(25)),
            child: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  contents.removeAt(index);
                  contents.insert(
                      index,
                      Container(
                        height: 0,
                      ));
                  contentsMap[index] = null;
                  contentType.removeAt(index);
                  contentType.insert(index, 'null');
                  contentsInfo[index] = null;
                });
              },
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.black38, borderRadius: BorderRadius.circular(25)),
          child: IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () {},
          ),
        ),
      ]),
    );
  }

  Widget createPostItemButton(
      {bool popupButton,
      Widget icon,
      List<PopupMenuItem> popupMenuItems,
      Function function}) {
    return !popupButton
        ? IconButton(icon: icon, onPressed: function)
        : PopupMenuButton(
            itemBuilder: (_) => popupMenuItems,
            icon: icon,
            onSelected: function,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Container(
            margin: EdgeInsets.all(5),
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          title: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              margin: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  createPostItemButton(
                      popupButton: true,
                      icon: Icon(
                        Icons.image,
                        color: Theme.of(context).primaryColor,
                      ),
                      popupMenuItems: [
                        PopupMenuItem(
                            child: Text('Camera'),
                            value: ContentInsertOptions.Camera),
                        PopupMenuItem(
                            child: Text('Device'),
                            value: ContentInsertOptions.Device),
                      ],
                      function: (selectedValue) {
                        if (selectedValue == ContentInsertOptions.Camera) {
                          handleTakePhoto();
                        } else {
                          handleChooseImageFromGallery();
                        }
                      }),
                  Container(
                    height: 20,
                    child: VerticalDivider(color: Colors.grey),
                    width: 1,
                  ),
                  createPostItemButton(
                      popupButton: true,
                      icon: Icon(
                        Icons.videocam,
                        color: Theme.of(context).primaryColor,
                      ),
                      popupMenuItems: [
                        PopupMenuItem(
                            child: Text('Camera'),
                            value: ContentInsertOptions.Camera),
                        PopupMenuItem(
                            child: Text('Device'),
                            value: ContentInsertOptions.Device),
                      ],
                      function: (selectedValue) {
                        if (selectedValue == ContentInsertOptions.Camera) {
                          handleTakeVideo();
                        } else {
                          handleChooseVideoFromGallery();
                        }
                      }),
                  Container(
                    height: 20,
                    child: VerticalDivider(color: Colors.grey),
                    width: 1,
                  ),
                  createPostItemButton(
                      popupButton: false,
                      icon: Icon(
                        Icons.text_fields,
                        color: Theme.of(context).primaryColor,
                      ),
                      popupMenuItems: null,
                      function: () {
                        TextEditingController textController =
                            TextEditingController();
                        setState(() {
                          textControllers.add(textController);
                          fileIndex++;
                          contents.add(textDisplay(textController, fileIndex));
                        });
                      }),
                  Container(
                    height: 20,
                    child: VerticalDivider(color: Colors.grey),
                    width: 1,
                  ),
                  createPostItemButton(
                      popupButton: false,
                      icon: Icon(
                        Icons.link,
                        color: Theme.of(context).primaryColor,
                      ),
                      popupMenuItems: null,
                      function: () {
                        TextEditingController linkController =
                            TextEditingController();
                        setState(() {
                          linkControllers.add(linkController);
                          fileIndex++;
                          contents.add(linkDisplay(linkController, fileIndex));
                        });
                      }),
                ],
              )),
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              margin: EdgeInsets.all(5),
              alignment: Alignment.center,
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(SelectTopicScreen.routeName, arguments: {
                    'post-function': handleSubmit,
                  });
                },
                child: Text(
                  'Next',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            PostScreenCommonWidget(
              captionController: titleController,
              currentUser: currentUser,
            ),
            Column(
              children: contents,
            )
          ],
        ));
  }
}
