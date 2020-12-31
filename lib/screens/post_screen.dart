// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:postgrest/postgrest.dart';
// Project imports:
import 'package:blue/main.dart';
import 'package:blue/providers/submit_state.dart';
import 'package:blue/screens/select_topic_screen.dart';
import 'package:blue/services/link_preview.dart';
import 'package:blue/services/video_controls.dart';
import 'package:blue/widgets/show_dialog.dart';
import '../services/file_storage.dart';
import '../services/video_processing.dart';
import './home.dart';

enum ContentInsertOptions { Device, Camera, Carousel }

class PostScreen extends StatefulWidget {
  static const routeName = '/post';
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Widget> contents = [
    //**choose btween container and widget due to zefyr
    Container(),
  ];
  List<File> videos = [];
  List<File> images = [];
  List<String> texts = [];
  bool isImage = true; //TODO: check if the file is image file
  int fileIndex = 0;
  bool isUploading = false;
  FlickManager flickManager;
  VideoPlayerController _videoPlayerController;
  TextEditingController titleController = TextEditingController();
  TextEditingController currentTextController = TextEditingController();
  List<TextEditingController> textControllers = List();
  bool editingText = false;
  List<FocusNode> textFocusNodes = List();
  List<TextEditingController> linkControllers = List();
  Map<int, dynamic> contentsMap = {};
  Map<String, dynamic> firestoreContents = {};
  Map<int, Map> contentsInfo = {};
  Map<String, Map> firestoreContentsInfo = {};
  Map<int, String> videoSources = {};
  List contentsData =
      []; //////////////////////////////////////////////////////////////////////////////
  List<String> contentType = [];
  String imageId = Uuid().v4();
  String videoId = Uuid().v4();
  String postId = Uuid().v4();
  File compressedFile;
  bool isDrafted = false;

  handleTakePhoto() async {
    File _cameraImage;
    var picker = ImagePicker();
    var pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 960,
      maxWidth: 960,
    );
    _cameraImage = File(pickedFile.path);
    addImageContent(_cameraImage);
  }
addImageContent(File _image)async{
   fileIndex++;
    double _aspectRatio;
    var decodedImage =
        await decodeImageFromList(_image.readAsBytesSync());
    _aspectRatio =
        decodedImage.width.toDouble() / decodedImage.height.toDouble();
    Map infoMap = {}; //
    infoMap['type'] = 'image'; //
    infoMap['aspectRatio'] = _aspectRatio; //
    contentsInfo[fileIndex] = infoMap; //
    setState(() {
      if (_image == null) {
        print('File is not available');
      } else {
        contentsData.add({
          'info': {'type': 'image', 'aspectRatio': _aspectRatio},
          'content': _image,
          'widget': imageDisplay(_image, fileIndex, _aspectRatio)
        });
        contents.add(imageDisplay(_image, fileIndex, _aspectRatio));
      }
    });
}
   handleChooseImageFromGallery() async {
    File _galleryImage;
    var picker = ImagePicker();
    var pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    _galleryImage = File(pickedFile.path);
   addImageContent(_galleryImage);
  }
  
  handleTakeVideo() async {
    File _cameraVideo;
    var picker = ImagePicker();
    var pickedFile = await picker.getVideo(source: ImageSource.camera);
    _cameraVideo = File(pickedFile.path);
     addVideoContent(_cameraVideo);
  
  }
  addVideoContent(File _video){
     fileIndex++;
    _videoPlayerController = VideoPlayerController.file(_video)
      ..initialize().then((_) {
        flickManager = FlickManager(
          videoPlayerController:  _videoPlayerController ,
        );
        setState(() {
          contentsData.add({
            'info': {
              'type': 'video',
              'aspectRatio': _videoPlayerController.value.aspectRatio
            },
            'content': _video,
            'widget': Container(child: VideoDisplay(flickManager, false))
          });

          if ( _videoPlayerController.value.isPlaying == true) {
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
   addVideoContent(_galleryVideo);
  }

 

  List<Asset> resultList = List<Asset>();
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
      if( resultList.length == 0){
        return;
      }
    } on Exception catch (e) {
      error = e.toString();//show error
      return;
    }
   
    if (!mounted) return;
    List carouselData = await getCarouselImages(resultList);
  
    List<File> carouselImages = carouselData[0];
    double _aspectRatio = carouselData[1];
  addCarouselContent( carouselImages, _aspectRatio);
  }
   addCarouselContent(List<File> carouselImages,  double _aspectRatio){
 fileIndex++;
    setState(() {
      contentsData.add({
        'info': {'type': 'carousel', 'aspectRatio': _aspectRatio},
        'content': carouselImages,
        'widget': carouselDisplay(carouselImages, fileIndex, _aspectRatio)
      });
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

  Future<String> uploadImage(File file) async {
    //Upload Profile Photo
    String _url =
        await FileStorage.upload('posts/$postId', 'image_$imageId', file);
    return _url;
  }

  Future<List<String>> uploadCarousel(List<File> files) async {
    List<String> downloadUrls = [];
    for (int i = 0; i < files.length; i++) {
      String _imageId = Uuid().v4();
      String _url = await FileStorage.upload(
          'posts/$postId', 'carousel_$_imageId', files[i]);
      downloadUrls.add(_url);
    }
    return downloadUrls;
  }

  Future<String> uploadVideo(dynamic mediaInfo) async {
    String _videoId = Uuid().v4();
    String _url = await FileStorage.upload(
        'posts/$postId', 'video_$_videoId', mediaInfo.file);
    return _url;
  }

  createPostInFirestore(
      {Map<String, dynamic> contents,
      String title,
      Map<String, Map> contentsInfo,
      String topicName,
      String topicId,
      List<String> tags}) async {
// var url = 'postgres://postgres:$supaPass@db.tauylgkvskndhqcgzpls.supabase.co:5432/postgres';
// var client = PostgrestClient(url);
// var response = await client.from('posts').
//       insert([
//         { 'username': 'supabot', 'status': 'ONLINE'}
//       ])
//       .execute();

    var lastDoc = await userPostsRef
        .doc(currentUser.id)
        .collection('userPosts')
        .orderBy('order', descending: true)
        .limit(1)
        .get();

    postsRef.doc(postId).set({
      'postId': postId,
      'ownerId': currentUser?.id,
      'username':
          currentUser?.username, //TODO username is not set in google accounts
      'photoUrl': currentUser.photoUrl,
      'contents': contents,
      'contentsInfo': contentsInfo,
      'title': title,
      'timeStamp': timestamp, // TODO: Remove
      'topicId': topicId,
      'topicName': topicName,
      'tags': tags,
      'ownerName': currentUser?.username,
      'upvotes': 0,
      'downvotes': 0,
      'votes': 0
    }); // TODO: check if successful

    if (lastDoc.docs.length == 0) {
      userPostsRef.doc(currentUser.id).collection('userPosts').doc().set({
        'order': 1,
        'posts': [
          postId,
        ],
      }, SetOptions(merge: true));
    } else if (lastDoc.docs.length == 1 &&
        lastDoc.docs.first.data()['posts'].length < 2) {
      List<dynamic> _postIdList = lastDoc.docs.first.data()['posts'];
      _postIdList.add(postId);
      userPostsRef
          .doc(currentUser.id)
          .collection('userPosts')
          .doc(lastDoc.docs.first.id)
          .set({
        'posts': _postIdList,
      }, SetOptions(merge: true));
    } else if (lastDoc.docs.length == 1 &&
        lastDoc.docs.first.data()['posts'].length > 1) {
      userPostsRef.doc(currentUser.id).collection('userPosts').doc().set({
        'order': lastDoc.docs.first.data()['order'] + 1,
        'posts': [
          postId,
        ],
      }, SetOptions(merge: true));
    }
  }

  Future<String> _uploadFile(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);
    String videoUrl =
        await FileStorage.upload('posts/$postId/$folderName', basename, file);
    return videoUrl;
  }

  Future<String> _uploadHLSFiles(dirPath, videoName) async {
    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    for (FileSystemEntity file in files) {
      final fileName = p.basename(file.path);
      final exploded = fileName.split('.');
      final fileExtension = exploded[exploded.length - 1];
      if (fileExtension == 'm3u8') _updatePlaylistUrls(file, videoName);
      final downloadUrl = await _uploadFile(file.path, videoName);

      if (fileName == 'master.m3u8') {
        playlistUrl = downloadUrl;
      }
    }
    return playlistUrl;
  }

  void _updatePlaylistUrls(File file, String videoName) {
    final lines = file.readAsLinesSync();
    var updatedLines = List<String>();

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = '$videoName%2F$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final updatedContents =
        updatedLines.reduce((value, element) => value + '\n' + element);

    file.writeAsStringSync(updatedContents);
  }

  Future<Map<String, String>> _processVideo(File file) async {

    final FlutterFFmpeg _encoder = FlutterFFmpeg();

    final info = await VideoProcessing.getMediaInformation(file.path);
    print(info);
    final aspectRatio = VideoProcessing.getAspectRatio(info);
    double videoHeight;
    double videoWidth;
    if (aspectRatio >= 1) {
      videoHeight = 540;
      videoWidth = 540 * aspectRatio;
    } else {
      videoWidth = 540;
      videoHeight = 540 / aspectRatio;
    }

    Directory appDocumentDir = await getExternalStorageDirectory();
    final String outDir = '${appDocumentDir.path}/Videos/$postId';
    final videosDir = new Directory(outDir);
    videosDir.createSync(recursive: true);
    String tempArguments = '';
    videoWidth = 960;
    videoHeight = 540;
    print('${VideoProcessing.checkAudio(info)}');
    if (VideoProcessing.checkAudio(info)) {
      tempArguments = '-y -i ${file.path} ' +
          '-preset fast -g 48 -sc_threshold 0 ' +
          '-map 0:0 -map 0:1 -map 0:0 -map 0:1 ' +
          '-r:v:1 24 -s:v:1 ${videoWidth.toInt()}x${videoHeight.toInt()} -c:v:1 libx265 -b:v:1 900k ' +
          '-r:v:0 24 -s:v:0 ${(videoWidth * (360 / 540)).toInt()}x${(videoHeight * (360 / 540)).toInt()} -c:v:0 libx265 -b:v:0 145k ' +
          '-c:a copy ' +
          '-var_stream_map "v:0,a:0 v:1,a:1" ' +
          '-master_pl_name master.m3u8 ' +
          '-f hls -hls_time 6 -hls_list_size 0 ' +
          '-hls_segment_filename "$outDir/%v_fileSequence_%d.ts" ' +
          '$outDir/%v_playlistVariant.m3u8';
    } else {
      tempArguments = '-y -i ${file.path} ' +
          '-preset fast -g 48 -sc_threshold 0 ' +
          '-map 0:0 -map 0:0 ' +
          '-r:v:1 24 -s:v:1 ${videoWidth.toInt()}x${videoHeight.toInt()} -c:v:1 libx265 -b:v:1 900k ' +
          '-r:v:0 24 -s:v:0 ${(videoWidth * (360 / 540)).toInt()}x${(videoHeight * (360 / 540)).toInt()} -c:v:0 libx265 -b:v:0 145k ' +
          '-var_stream_map "v:0 v:1" ' +
          '-master_pl_name master.m3u8 ' +
          '-f hls -hls_time 6 -hls_list_size 0 ' +
          '-hls_segment_filename "$outDir/%v_fileSequence_%d.ts" ' +
          '$outDir/%v_playlistVariant.m3u8';
    }
    await _encoder
        .execute(tempArguments)
        .then((rc) => print("FFmpeg process exited with rc $rc"));

    String thumbFilePath = await VideoProcessing.getThumb(
        file.path,
        (videoWidth * (300 / 540)).toInt(),
        (videoHeight * (300 / 540)).toInt());

    final String thumbUrl = await _uploadFile(thumbFilePath, 'thumbnail');
    final String videoUrl = await _uploadHLSFiles(outDir, 'video_$postId');
    print('$thumbUrl  $videoUrl');
    return {'thumbUrl': thumbUrl, 'videoUrl': videoUrl};
  }

  handleSubmit(String topicName, List<String> tags) async {
    setState(() {
      isUploading = true;
    });
    int x = 0;
    for (int i = 0; i < contentsData.length; i++) {
      if (contentsData[i]['info']['type'] == 'null') {
      } else if (contentsData[i]['info']['type'] == 'link') {
        firestoreContents['$x'] = contentsData[i]['content'].text;
        firestoreContentsInfo['$x'] = contentsData[i]['info'];
        x++;
      } else if (contentsData[i]['info']['type'] == 'text') {
        firestoreContents['$x'] = contentsData[i]['content'].text;
        firestoreContentsInfo['$x'] = contentsData[i]['info'];
        x++;
      } else if (contentsData[i]['info']['type'] == 'image') {
        File imageFile = await compressImage(contentsData[i]['content']);
        String mediaUrl = await uploadImage(imageFile);
        firestoreContents['$x'] = mediaUrl;
        firestoreContentsInfo['$x'] = contentsData[i]['info'];
        x++;
      } else if (contentsData[i]['info']['type'] == 'video') {
        Map _videoData = await _processVideo(contentsData[i]['content']);
        firestoreContents['$x'] = _videoData['videoUrl'];
        contentsData[i]['info']['thumbUrl'] = _videoData['thumbUrl'];
        firestoreContentsInfo['$x'] = contentsData[i]['info'];
        x++;
      } else if (contentsData[i]['info']['type'] == 'carousel') {
        List<String> mediaUrl =
            await uploadCarousel(contentsData[i]['content']);
        firestoreContents['$x'] = mediaUrl;
        firestoreContentsInfo['$x'] = contentsData[i]['info'];
        x++;
      }
    }
    await createPostInFirestore(
        contents: firestoreContents,
        title: titleController.text,
        contentsInfo: firestoreContentsInfo,
        topicName: topicName,
        tags: tags);

    titleController.clear();
    textControllers = [];
    setState(() {
      isUploading = false;
      imageId = Uuid().v4();
      videoId = Uuid().v4();
      firestoreContents = {};
    });
    postReportsRef.doc(postId).set({
      'abusive': 0,
      'inappropriate': 0,
      'spam': 0,
    });
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget textDisplay(TextEditingController textController, int index,
      FocusNode textFocusNode) {
    Map infoMap = {};
    infoMap['type'] = 'text';
    contentsInfo[index] = infoMap;
    contentsMap[index] = textController;
    contentType.add('text');
    print(contentsMap);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: TextField(
          controller: textController,
          focusNode: textFocusNode,
          keyboardType: TextInputType.multiline,
          decoration:
              InputDecoration(hintText: 'Text...', border: InputBorder.none),
          maxLines: null,
          onTap: () {
            if (editingText = false) {
              setState(() {
                editingText = true;
                currentTextController = textController;
              });
            }
          },
        ));
  }

  Container linkDisplay(TextEditingController linkController, bool isLoading,
      {bool error}) {
    return Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      child: TextField(
        textAlign: TextAlign.center,
        controller: linkController,
        decoration: InputDecoration(
          hintText: 'Link',
          hintStyle: TextStyle(
              color: Theme.of(context).iconTheme.color.withOpacity(0.8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 3),
          suffixIcon: isLoading
              ? Container(
                  padding:
                      EdgeInsets.only(right: 13, top: 13, bottom: 13, left: 13),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                )
              : Container(
                  width: 0,
                ),
          prefixIcon: Icon(
            FlutterIcons.link_fea,
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
            borderSide: BorderSide(
                color: error == true ? Colors.red : Colors.grey, width: 3),
          ),
        ),
        keyboardType: TextInputType.url,
        maxLines: 1,
        onSubmitted: (controller) {
          verifyLink(linkController);
        },
      ),
    );
  }

  void verifyLink(TextEditingController linkController) async {
    String _url = linkController.text.toLowerCase();

    if (!isURL(_url, {
      'protocols': ['http', 'https'],
      'require_tld': true,
      'require_protocol': false,
    })) {
      showErrorLinkDisplay(linkController);

      return;
    }
    setState(() {
      contentsData.firstWhere((element) {
        if (element['content'] == linkController) {
          return true;
        }
        return false;
      })['widget'] = linkDisplay(linkController, true);
    });
    Response response;
    bool errorOccured = false;
    _url = linkController.text.toLowerCase().trim();
    if (!(_url.startsWith(
          'http://',
        ) ||
        _url.startsWith(
          'https://',
        ))) {
      _url = 'https://$_url';
    }
    try {
      response = await head(_url);
    } catch (error) {
      errorOccured = true;
    }
    if (!errorOccured && response.statusCode == 200) {
      Container _display;
      try {
        _display = linkImageDisplay(linkController.text);
      } catch (e) {
        showErrorLinkDisplay(linkController);
        return;
      }
      setState(() {
        contents.add(_display);
        contentsData.firstWhere((element) {
          if (element['content'] == linkController) {
            return true;
          }
          return false;
        })['widget'] = _display;
      });
    } else {
      showErrorLinkDisplay(linkController);
    }
  }

  showErrorLinkDisplay(TextEditingController linkController) async {
    setState(() {
      contentsData.firstWhere((element) {
        if (element['content'] == linkController) {
          return true;
        }
        return false;
      })['widget'] = linkDisplay(linkController, false, error: true);
    });
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      contentsData.firstWhere((element) {
        if (element['content'] == linkController) {
          return true;
        }
        return false;
      })['widget'] = linkDisplay(linkController, false, error: false);
    });
  }

  Container linkImageDisplay(String link) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Theme.of(context).canvasColor),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinkPreview(
              url: link,
              bodyStyle: TextStyle(fontSize: 13),
              titleStyle: TextStyle(fontWeight: FontWeight.w500),
              showMultimedia: true,
            )));
  }

  Container imageDisplay(File file, int index, double aspectRatio) {
    contentsMap[index] = file; //
    contentType.add('image'); //
    return Container(
      key: ValueKey(index),
      child: AspectRatio(
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
        child: Container(
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
            )));
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
    flickManager?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    int _postId = ModalRoute.of(context).settings.arguments;
    if (_postId != null) {
      var _postData = draftBox.values.elementAt(_postId);
      setState(() {
      _postData['contentsData'].forEach((data) {
          switch (data['info']['type']) {
            case 'text':
            TextEditingController textController =
                            TextEditingController(text:data['content'] );
                        FocusNode textFocusNode = FocusNode();
                        setState(() {
                          textControllers.add(textController);
                          textFocusNodes.add(textFocusNode);
                          fileIndex++;
                          contentsData.add({
                            'info': {'type': 'text'},
                            'content': textController,
                            'widget': textDisplay(
                                textController, fileIndex, textFocusNode)
                          });
                          contents.add(textDisplay(
                              textController, fileIndex, textFocusNode));
                        });
              break;
            case 'link':
               TextEditingController linkController =
                            TextEditingController(text:data['content'] );
                        setState(() {
                          linkControllers.add(linkController);
                          fileIndex++;
                          contentsData.add({
                            'info': {'type': 'link'},
                            'content': linkController,
                            'widget': linkDisplay(linkController, false)
                          });
                        });
              break;
            case 'image':
             addImageContent(File(data['content']));
              break;
            case 'video':
            addVideoContent(File(data['content']));
              break;
               case 'carousel':
               List<File> _images = [];
             data['content'].forEach((img) {
                  _images.add(File(img));
              });
            addCarouselContent(_images, data['info']['aspectRatio']);
              break;
          }
        });
        // _postData['contentsData'].
        titleController = TextEditingController(text: _postData['title']);
        isDrafted = true;
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _contents = [];
    // draftBox.deleteAll([0,1]);
    for (int i = 0; i < contentsData.length; i++) {
      _contents.add(GestureDetector(
          onLongPress: () {
            showContentSettingsSheet(i + 1);
          },
          child: contentsData[i]['widget']));
    }
    print(draftBox.values);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
          elevation: 0.5,
          leading: IconButton(
              icon: Icon(
                Icons.clear,
              ),
              onPressed: () {
                if (isDrafted) {
                  Navigator.pop(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => ShowDialog(
                      title: "Save as Draft",
                      description: "Do you want to save your work as Draft?",
                      rightButtonText: "Save Draft",
                      leftButtonText: "Cancel",
                      rightButtonFunction: () async {
                        List<Map> _modifiedContentsData = contentsData;
                        Directory appDocDir;
                        appDocDir = await getApplicationDocumentsDirectory();
                        await Directory(appDocDir.path + '/posts/$postId')
                            .create(recursive: true);

                        // Directory(_storageInfo[0].rootDir + '/MyCreatedFolder').create();
                        for (int i = 0; i < _modifiedContentsData.length; i++) {
                          _modifiedContentsData[i].remove('widget');
                          switch (_modifiedContentsData[i]['info']['type']) {
                            case 'image':
                              final _fileName = Path.basename(
                                  _modifiedContentsData[i]['content'].path);
                              String _path =
                                  appDocDir.path + '/posts/$postId/$_fileName';
                              await _modifiedContentsData[i]['content']
                                  .copy(_path);
                              _modifiedContentsData[i]['content'] = _path;
                              break;
                            case 'video':
                              print('its video draft content');
                              final _fileName = Path.basename(
                                  _modifiedContentsData[i]['content'].path);
                              String _path =
                                  appDocDir.path + '/posts/$postId/$_fileName';
                              await _modifiedContentsData[i]['content']
                                  .copy(_path);
                              _modifiedContentsData[i]['content'] = _path;
                              break;
                            case 'carousel':
                              String _path = appDocDir.path + '/posts/$postId';
                              List _paths = [];
                              for (int f = 0;
                                  f <
                                      _modifiedContentsData[i]['content']
                                          .length;
                                  f++) {
                                var _fileName = Path.basename(
                                    _modifiedContentsData[i]['content'][f]
                                        .path);
                                await _modifiedContentsData[i]['content'][f]
                                    .copy(_path + '/$_fileName');
                                _paths.add(_path + '/$_fileName');
                              }
                              _modifiedContentsData[i]['content'] = _paths;
                              break;
                            case 'text':
                              _modifiedContentsData[i]['content'] =
                                  contentsData[i]['content'].text;
                              break;
                            case 'link':
                              _modifiedContentsData[i]['content'] =
                                  contentsData[i]['content'].text;
                              break;
                            default:
                          }
                        }

                        draftBox.add({
                          'title': titleController.text,
                          'contentsData': _modifiedContentsData,
                          'postId': postId
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      leftButtonFunction: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                }
              }),
          centerTitle: true,
          title: Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              elevation: 1,
              semanticContainer: false,
              color: Theme.of(context).backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(FlutterIcons.image_fea),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => postItemsDialog({
                          'Camera': handleTakePhoto,
                          'Device': handleChooseImageFromGallery,
                          'Multiple': handleCreateCarousel,
                        }, context),
                      );
                    },
                  ),
                  IconButton(
                    padding: EdgeInsets.only(top: 2),
                    icon: Icon(
                      FlutterIcons.video_fea,
                      size: 25.5,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => postItemsDialog({
                          'Camera': handleTakeVideo,
                          'Device': handleChooseVideoFromGallery,
                        }, context),
                      );
                    },
                  ),
                  IconButton(
                      icon: Icon(
                        FlutterIcons.text_ent,
                      ),
                      onPressed: () {
                        TextEditingController textController =
                            TextEditingController();
                        FocusNode textFocusNode = FocusNode();
                        setState(() {
                          textControllers.add(textController);
                          textFocusNodes.add(textFocusNode);
                          fileIndex++;
                          contentsData.add({
                            'info': {'type': 'text'},
                            'content': textController,
                            'widget': textDisplay(
                                textController, fileIndex, textFocusNode)
                          });
                          contents.add(textDisplay(
                              textController, fileIndex, textFocusNode));
                        });
                      }),
                  IconButton(
                      icon: Icon(
                        FlutterIcons.link_fea,
                        size: 21,
                      ),
                      onPressed: () {
                        TextEditingController linkController =
                            TextEditingController();
                        setState(() {
                          linkControllers.add(linkController);
                          fileIndex++;
                          contentsData.add({
                            'info': {'type': 'link'},
                            'content': linkController,
                            'widget': linkDisplay(linkController, false)
                          });
                        });
                      }),
                ],
              )),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                print(contentsData);
                Navigator.of(context)
                    .pushNamed(SelectTopicScreen.routeName, arguments: {
                  'post-function': handleSubmit,
                });
              },
              icon: Icon(
                FlutterIcons.ios_arrow_forward_ion,
                color: Colors.blue,
                size: 30,
              ),
            )
          ],
          backgroundColor: Theme.of(context).canvasColor //TODO blue gradient
          ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              width: double.infinity,
              child: TextField(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                maxLines: 2,
                minLines: 1,
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(
                      color:
                          Theme.of(context).iconTheme.color.withOpacity(0.8)),
                  border: InputBorder.none,
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 1,
              thickness: 0.3,
            ),
            if (_contents.length > 0)
              Column(
                children: _contents,
              )
            else
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        FluentIcons.collections_add_24_regular,
                        size: 95,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  postItemsDialog(Map functions, BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        decoration: new BoxDecoration(
          color: Theme.of(context).canvasColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: const Offset(0.0, 5.0),
            ),
          ],
        ),
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (_, i) {
            return InkWell(
              onTap: () {
                Navigator.of(context).pop();
                functions.values.elementAt(i)();
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 0.3, color: Colors.grey))),
                child: Text(
                  functions.keys.elementAt(i),
                  style: TextStyle(fontSize: 18),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            );
          },
          itemCount: functions.length,
        ),
      ),
    );
  }

  showContentSettingsSheet(int index) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) => ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: new BoxDecoration(
                  color: Theme.of(context).canvasColor,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    ListTile(
                      onTap: () {
                        setState(() {
                          contentsData.removeAt(index - 1);
                          Navigator.pop(context);
                        });
                      },
                      leading: Icon(
                        Icons.clear,
                        color: Colors.red,
                      ),
                      title: Text('Remove'),
                    ),
                    if (index > 1)
                      ListTile(
                        onTap: () {
                          setState(() {
                            var upperContent = contentsData[index - 2];
                            contentsData[index - 2] = contentsData[index - 1];
                            contentsData[index - 1] = upperContent;
                            Navigator.pop(context);
                          });
                        },
                        title: Text('Move Up'),
                        leading: Icon(
                          Icons.arrow_upward,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    if (index < contentsData.length)
                      ListTile(
                        onTap: () {
                          setState(() {
                            var lowerContent = contentsData[index];
                            contentsData[index] = contentsData[index - 1];
                            contentsData[index - 1] = lowerContent;
                            Navigator.pop(context);
                          });
                        },
                        leading: Icon(
                          Icons.arrow_downward,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        title: Text('Move Down'),
                      ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ));
  }
}
