import 'package:blue/screens/select_topic_screen.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:video_compress/video_compress.dart' as Vc;
import 'package:flutter_video_compress/flutter_video_compress.dart' as Fvc;
import 'dart:io';
import './home.dart';
import 'package:http/http.dart';
import 'package:blue/widgets/post_screen_common_widget.dart';
import 'package:blue/main.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:link_previewer/link_previewer.dart';

enum ContentInsertOptions { Device, Camera, Carousel }

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
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> textControllers = List();
  List<TextEditingController> linkControllers = List();
  Map<int, dynamic> contentsMap = {};
  Map<String, dynamic> firestoreContents = {};
  Map<int, Map> contentsInfo = {};
  Map<String, Map> firestoreContentsInfo = {};
  Map<int, String> videoSources = {};
  List<String> contentType = [];
  String imageId = Uuid().v4();
  String videoId = Uuid().v4();
  String postId = Uuid().v4();
  File compressedFile;
  
  handleTakePhoto() async {
    File _cameraImage;
    var picker = ImagePicker();
    var pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 960,
      maxWidth: 960,
    );
    _cameraImage = File(pickedFile.path);
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
  }

  handleTakeVideo() async {
    File _cameraVideo;
    var picker = ImagePicker();
    var pickedFile = await picker.getVideo(source: ImageSource.camera);
    _cameraVideo = File(pickedFile.path);
    fileIndex++;
    _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo)
      ..initialize().then((_) {
        setState(() {
          contents.add(videoDisplay(
              _cameraVideo, _cameraVideoPlayerController, fileIndex, 'camera'));
          // _cameraVideoPlayerController.play();
          if (_cameraVideoPlayerController.value.isPlaying == true) {
            print('amsdd');
          }
        });
      });
  }

  handleChooseVideoFromGallery() async {
    File _galleryVideo;
    var picker = ImagePicker();
    var pickedFile = await picker.getVideo(
      source: ImageSource.gallery,
    );
    _galleryVideo = File(pickedFile.path);
    fileIndex++;
    _videoPlayerController = VideoPlayerController.file(_galleryVideo)
      ..initialize().then((_) {
        setState(() {
          contents.add(
              videoDisplay(_galleryVideo, _videoPlayerController, fileIndex, 'gallery'));
          // _videoPlayerController.play();
          if (_videoPlayerController.value.isPlaying == true) {
            print('msdd');
          }
        });
      });
  }

  handleChooseImageFromGallery() async {
    File _galleryImage;
    var picker = ImagePicker();
    var pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    _galleryImage = File(pickedFile.path);
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
      contents.add(imageDisplay(_galleryImage, fileIndex, aspectRatio,));
    });
    // compressImage(fileIndex);
  }

  List<Asset> resultList = List<Asset>();
  loadCarouselImages() async {
    // try {
    resultList = await MultiImagePicker.pickImages(
      maxImages: 12,
      enableCamera: true,
      cupertinoOptions: CupertinoOptions(
        takePhotoIcon: "chat",
      ),
      materialOptions: MaterialOptions(
        actionBarColor: "#147efb",
        actionBarTitle: "Scrible",
        allViewTitle: "All Images",
        useDetailsView: false,
        selectCircleStrokeColor: "#000000",
      ),
    );
  }

  String error = 'No Error Dectected';
  Future<void> handleCreateCarousel() async {
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 12,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
        ),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Scrible",
          allViewTitle: "All Images",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    fileIndex++;
    if (!mounted) return;
    List carouselData = await getCarouselImages(resultList);
    List<File> carouselImages = carouselData[0];
    double _aspectRatio = carouselData[1];

    setState(() {
      contents.add(carouselDisplay(carouselImages, fileIndex, _aspectRatio));
    });
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

  compressCameraVideo(File file) async {
    Fvc.MediaInfo info = await Fvc.FlutterVideoCompress().compressVideo(
      file.path,
      quality:
          Fvc.VideoQuality.HighestQuality, // default(VideoQuality.DefaultQuality)
      deleteOrigin: false, // default(false)
    );
    return info;
   
    
  }
    compressGalleryVideo(File file) async {
      Vc.MediaInfo info = await Vc.VideoCompress.compressVideo(
      file.path,
      quality: Vc.VideoQuality.MediumQuality,
      deleteOrigin: false, 

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

  Future<List<String>> uploadCarousel(List<File> files) async {
    List<String> downloadUrls = [];
    StorageTaskSnapshot storageSnap;
    String downloadUrl;
    for (int i = 0; i < files.length; i++) {
      imageId = Uuid().v4();
      StorageUploadTask uploadTask = storageRef
          .child("post_$imageId.jpg")
          .putFile(files[i], StorageMetadata(contentType: 'jpg'));
      storageSnap = await uploadTask.onComplete;
      downloadUrl = await storageSnap.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return  downloadUrls;
  }

  Future<String> uploadVideo(dynamic mediaInfo) async {
    StorageUploadTask uploadTask =
        storageRef.child('video_$videoId.mp4').putFile(mediaInfo.file);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {Map<String, dynamic> contents,
      String title,
      Map<String, Map> contentsInfo,
      String topicName,
      String topicId,
      List<String> tags}) async {
    var lastDoc = await userPostsRef
        .document(currentUser.id)
        .collection('userPosts')
        .orderBy('order', descending: true)
        .limit(1)
        .getDocuments();

    postsRef.document(postId).setData({
      'postId': postId,
      'ownerId': currentUser?.id,
      'username': currentUser?.username,
      'photoUrl': currentUser.photoUrl,
      'contents': contents,
      'contentsInfo': contentsInfo,
      'title': title,
      'timeStamp': timestamp, // TODO: Remove
      'topicId': topicId,
      'topicName': topicName,
      'tags': tags,
      'ownerName': currentUser?.username,
    }); // TODO: check if successful
    if (lastDoc.documents.length == 0) {
      userPostsRef
          .document(currentUser.id)
          .collection('userPosts')
          .document()
          .setData({
        'order': 1,
        'posts': [
          postId,
        ],
      }, merge: true);
    } else if (lastDoc.documents.length == 1 &&
        lastDoc.documents.first.data['posts'].length < 2) {
      List<dynamic> _postIdList = lastDoc.documents.first.data['posts'];
      _postIdList.add(postId);
      userPostsRef
          .document(currentUser.id)
          .collection('userPosts')
          .document(lastDoc.documents.first.documentID)
          .setData({
        'posts': _postIdList,
      }, merge: true);
    } else if (lastDoc.documents.length == 1 &&
        lastDoc.documents.first.data['posts'].length > 1) {
      userPostsRef
          .document(currentUser.id)
          .collection('userPosts')
          .document()
          .setData({
        'order': lastDoc.documents.first.data['order'] + 1,
        'posts': [
          postId,
        ],
      }, merge: true);
    }
  }

  handleSubmit(String topicName, String topicId, List<String> tags) async {
    setState(() {
      isUploading = true;
    });
    int x = 0;
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
        dynamic videoMediaInfo ;
       if(videoSources[i] == 'gallery'){  videoMediaInfo =  await compressGalleryVideo(contentsMap[i]);}
       else{
       videoMediaInfo =  await compressCameraVideo(contentsMap[i]);
       }
        String mediaUrl = await uploadVideo(videoMediaInfo);
        firestoreContents['$x'] = mediaUrl;
        firestoreContentsInfo['$x'] = contentsInfo[i];
        x++;
      } else if (contentType[i - 1] == 'carousel') {
        List<String> mediaUrl = await uploadCarousel(contentsMap[i]);
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
        topicId: topicId,
        tags: tags);

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
    Navigator.pop(context);
  }
  
  Container videoDisplay(
      File file, VideoPlayerController videoController, int index,String source) {
    Map infoMap = {};
    infoMap['type'] = 'video';
    infoMap['aspectRatio'] = videoController.value.aspectRatio;
    contentsInfo[index] = infoMap;
    contentsMap[index] = file;
    contentType.add('video');
    videoSources[index] = source;
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
                color: Colors.black38, borderRadius: BorderRadius.circular(25),),
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
      setState(() {
        contents.add(linkImageDisplay(linkText));
      });
    }
  }

  Container linkImageDisplay(String link) {
    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinkPreviewer(
            link: link,
            backgroundColor: Theme.of(context).canvasColor,
            direction: ContentDirection.vertical,
            bodyMaxLines: 3,
            borderColor: Colors.white,
            borderRadius: 8,
            key: UniqueKey(),
            titleFontSize: 20,
          ),
        ));
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
      ]),
    );
  }

  Future<List<dynamic>> getCarouselImages(List<Asset> images) async {
    List<File> imageFiles = [];
    double firstAspectRatio = 1;
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    for (int i = 0; i < images.length; i++) {
      if (i == 0) {
        int firstHeight = images.first.originalHeight;
        int firstWidth = images.first.originalWidth;
        firstAspectRatio = firstWidth / firstHeight;
      }
      imageId = Uuid().v4();
      var byteData = await images.elementAt(i).getByteData();
      var _imageMemory = byteData.buffer.asUint8List();
      Im.Image decodedImage = Im.decodeImage(_imageMemory);
      final compressedImageFile = File('$path/img_$imageId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(decodedImage, quality: 85));
      imageFiles.add(compressedImageFile);
    }
    return [imageFiles, firstAspectRatio];
  }

  Container carouselDisplay(List<File> images, int index, double aspectRatio) {
    Map infoMap = {};
    infoMap['type'] = 'carousel';
    infoMap['aspectRatio'] = aspectRatio;
    contentsInfo[index] = infoMap;
    contentsMap[index] = images;
    contentType.add('carousel');
    return Container(
        height: MediaQuery.of(context).size.width / aspectRatio,
        key: UniqueKey(),
        child: Carousel(
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
          images: List.generate(images.length, (i) {
            return FileImage(images[i]);
          }),
        ));
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
  void dispose() {
    _videoPlayerController?.dispose();
      _cameraVideoPlayerController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
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
          centerTitle: true,
          title: Text('Create Post'),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
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
                          PopupMenuItem(
                              child: Text('Carousel'),
                              value: ContentInsertOptions.Carousel),
                        ],
                        function: (selectedValue) {
                          if (selectedValue == ContentInsertOptions.Camera) {
                            handleTakePhoto();
                          } else if (selectedValue ==
                              ContentInsertOptions.Device) {
                            handleChooseImageFromGallery();
                          } else {
                            handleCreateCarousel();
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
                            contents
                                .add(textDisplay(textController, fileIndex));
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
                            contents
                                .add(linkDisplay(linkController, fileIndex));
                          });
                        }),
                  ],
                )),
          ),
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
          backgroundColor: Colors.blue[700]                             //TODO blue gradient
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
