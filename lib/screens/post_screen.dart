import 'dart:convert';
import 'dart:ui';
import 'package:blue/providers/submit_state.dart';
import 'package:blue/screens/editor_field_screen.dart';
import 'package:blue/services/link_preview.dart';
import 'package:blue/widgets/show_dialog.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:blue/screens/select_topic_screen.dart';
import 'package:blue/services/video_controls.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart' as Vc;
import 'package:flutter_video_compress/flutter_video_compress.dart' as Fvc;
import 'package:visibility_detector/visibility_detector.dart';
import 'package:zefyr/zefyr.dart';
import 'dart:io';
import './home.dart';
import 'package:http/http.dart';
import 'package:blue/widgets/post_screen_common_widget.dart';
import 'package:blue/main.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:link_previewer/link_previewer.dart';
import '../services/video_processing.dart';
import 'package:path/path.dart' as Path;
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/src/widgets/field.dart';
enum ContentInsertOptions { Device, Camera, Carousel }

class PostScreen extends StatefulWidget {
  static const routeName = '/post';
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Widget> contents = [                            //**choose btween container and widget due to zefyr
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
  VideoPlayerController _cameraVideoPlayerController;
  TextEditingController titleController = TextEditingController();
  // List<TextEditingController> textControllers = List();
   List<ZefyrController> textControllers = List();
  List<FocusNode> textFocusNodes = List();
  List<TextEditingController> linkControllers = List();
  Map<int, dynamic> contentsMap = {};
  Map<String, dynamic> firestoreContents = {};
  Map<int, Map> contentsInfo = {};
  Map<String, Map> firestoreContentsInfo = {};
  Map<int, String> videoSources = {};
  List<Map<String, dynamic>> contentsData =
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
    fileIndex++;
    double _aspectRatio;
    var decodedImage =
        await decodeImageFromList(_cameraImage.readAsBytesSync());
    _aspectRatio =
        decodedImage.width.toDouble() / decodedImage.height.toDouble();
    Map infoMap = {}; //
    infoMap['type'] = 'image'; //
    infoMap['aspectRatio'] = _aspectRatio; //
    contentsInfo[fileIndex] = infoMap; //
    setState(() {
      if (_cameraImage == null) {
        print('File is not available');
      } else {
        contentsData.add({
          'info': {'type': 'image', 'aspectRatio': _aspectRatio},
          'content': _cameraImage,
          'widget': imageDisplay(_cameraImage, fileIndex, _aspectRatio)
        });
        contents.add(imageDisplay(_cameraImage, fileIndex, _aspectRatio));
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
        flickManager = FlickManager(
          videoPlayerController: _cameraVideoPlayerController,
        );
        setState(() {
          contentsData.add({
            'info': {
              'type': 'video',
              'aspectRatio': _cameraVideoPlayerController.value.aspectRatio
            },
            'content': _cameraVideo,
            'widget': Container(child: VideoDisplay(flickManager, false))
          });

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
        flickManager = FlickManager(
          videoPlayerController: _videoPlayerController,
        );
        setState(() {
          contentsData.add({
            'info': {
              'type': 'video',
              'aspectRatio': _videoPlayerController.value.aspectRatio
            },
            'content': _galleryVideo,
            'widget': Container(child: VideoDisplay(flickManager, false))
          });

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
    contentsData.add({
      'info': {'type': 'image', 'aspectRatio': aspectRatio},
      'content': _galleryImage,
      'widget': imageDisplay(_galleryImage, fileIndex, aspectRatio)
    });
    Map infoMap = {};
    infoMap['type'] = 'image';
    infoMap['aspectRatio'] = aspectRatio;
    contentsInfo[fileIndex] = infoMap;
    setState(() {
      contents.add(imageDisplay(
        _galleryImage,
        fileIndex,
        aspectRatio,
      ));
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
    return downloadUrls;
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

  Future<String> _uploadFile(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);
    final StorageReference ref =
        FirebaseStorage.instance.ref().child(folderName).child(basename);
    StorageUploadTask uploadTask = ref.putFile(file);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String videoUrl = await taskSnapshot.ref.getDownloadURL();
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
    var stateProvider = Provider.of<SubmitState>(context, listen: false);

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
    // return;
    // final outDirPath = '${extDir.path}/Videos/$videoName';
    // final videosDir = new Directory(outDirPath);
    // videosDir.createSync(recursive: true);

    String thumbFilePath = await VideoProcessing.getThumb(
        file.path,
        (videoWidth * (300 / 540)).toInt(),
        (videoHeight * (300 / 540)).toInt());

    final String thumbUrl = await _uploadFile(thumbFilePath, 'thumbnail');
    final String videoUrl = await _uploadHLSFiles(outDir, 'video_$postId');
    print('$thumbUrl  $videoUrl');
    return {'thumbUrl': thumbUrl, 'videoUrl': videoUrl};

    // final videoInfo = VideoInfo(
    //   videoUrl: videoUrl,
    //   thumbUrl: thumbUrl,
    //   coverUrl: thumbUrl,
    //   aspectRatio: aspectRatio,
    //   uploadedAt: DateTime.now().millisecondsSinceEpoch,
    //   videoName: videoName,
    // );

    // await FirebaseProvider.saveVideo(videoInfo);
  }

  handleSubmit(String topicName, String topicId, List<String> tags) async {
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

  Widget textDisplay(ZefyrController textController,
    // TextEditingController textController,
   int index,
      FocusNode textFocusNode) {
    Map infoMap = {};
    infoMap['type'] = 'text';
    contentsInfo[index] = infoMap;
    contentsMap[index] = textController;
    contentType.add('text');
    print(contentsMap);
    return 
    ZefyrField(      height: 200.0,
      decoration: InputDecoration(border: InputBorder.none, hintText: 'Text...',),
      controller: textController,key: UniqueKey(),
      focusNode: textFocusNode,
      autofocus: true,
      imageDelegate: CustomImageDelegate(),
      physics: AlwaysScrollableScrollPhysics(),
        // key: UniqueKey(),
        // padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        // child: TextField(
        //   controller: textController,
        //   focusNode: textFocusNode,
        //   key: UniqueKey(),
        //   decoration:
        //       InputDecoration(border: InputBorder.none, hintText: 'Text...'),
        //   keyboardType: TextInputType.multiline,
        //   maxLines: null,
        // )
        );
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
    setState(() {
      contentsData.firstWhere((element) {
        if (element['content'] == linkController) {
          return true;
        }
        return false;
      })['widget'] = linkDisplay(linkController, true);
    });
    Response response;
    // final response = await head(linkController.text);
    // print('${response.statusCode}');
    bool errorOccured = false;
    try {
      response = await head(linkController.text);
    } catch (error) {
      errorOccured = true;
    }
    if (!errorOccured && response.statusCode == 200) {
      setState(() {
        contents.add(linkImageDisplay(linkController.text));
        contentsData.firstWhere((element) {
          if (element['content'] == linkController) {
            return true;
          }
          return false;
        })['widget'] = linkImageDisplay(linkController.text);
        //      contentsData.add({
        //   'info': {'type':'link'},
        //   'content':   linkController,
        //   'widget':linkDisplay(linkController, fileIndex)
        // });
      });
    } else {
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
    _cameraVideoPlayerController?.dispose();
    flickManager?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    String _postId = ModalRoute.of(context).settings.arguments;
    if (_postId != null) {
      var _postData = preferences.get('drafts');
      Map _postDataMap = jsonDecode(_postData);
      setState(() {
        contentsData = _postDataMap['contentsData'];
        titleController =
            TextEditingController(text: _postDataMap['contentsData']);
        isDrafted = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _contents = [];
    print(contentsData);
    for (int i = 0; i < contentsData.length; i++) {
      _contents.add(GestureDetector(
          onLongPress: () {
            showContentSettingsSheet(i + 1);
          },
          child: contentsData[i]['widget']));
    }

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
                          // Directory(_storageInfo[0].rootDir + '/MyCreatedFolder').create();
                          for (int i = 0;
                              i < _modifiedContentsData.length;
                              i++) {
                            _modifiedContentsData[i].remove('widget');
                            switch (_modifiedContentsData[i]['info']['type']) {
                              case 'image':
                                final _fileName = Path.basename(
                                    _modifiedContentsData[i]['content'].path);
                                if (appDocDir == null)
                                  appDocDir =
                                      await getApplicationDocumentsDirectory();
                                String _path =
                                    appDocDir.path + '/$postId/$_fileName';
                                await _modifiedContentsData[i]['content']
                                    .copy(_path);
                                _modifiedContentsData[i]['content'] = _path;
                                break;
                              case 'video':
                                final _fileName = Path.basename(
                                    _modifiedContentsData[i]['content'].path);
                                if (appDocDir == null)
                                  appDocDir =
                                      await getApplicationDocumentsDirectory();
                                String _path =
                                    appDocDir.path + '/$postId/$_fileName';
                                await _modifiedContentsData[i]['content']
                                    .copy(_path);
                                _modifiedContentsData[i]['content'] = _path;
                                break;
                              case 'carousel':
                                if (appDocDir == null)
                                  appDocDir =
                                      await getApplicationDocumentsDirectory();
                                String _path = appDocDir.path + '/$postId';
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
                          var drafts = preferences.get('drafts');
                          if (drafts == null) {
                            drafts = jsonEncode({});
                            preferences.setString('drafts', drafts);
                          }

                          Map _drafts = jsonDecode(drafts);
                          _drafts[postId] = {
                            'title': titleController.text,
                            'contentsData': _modifiedContentsData
                          };
                          preferences.setString('drafts', jsonEncode(_drafts));
                          print(_drafts);
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
                          // TextEditingController textController =
                          //     TextEditingController();
                                ZefyrController textController =
                              ZefyrController(NotusDocument());
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
        body: ZefyrScaffold(
                  child: SingleChildScrollView(
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
                            size: 45,
                          ),
                        ),
                        Text(
                          'Add Content',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
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
        ));
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


class CustomImageDelegate implements ZefyrImageDelegate<ImageSource> {
  @override
  ImageSource get cameraSource => ImageSource.camera;

  @override
  ImageSource get gallerySource => ImageSource.gallery;

  @override
  Future<String> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.getImage(source: source);
    if (file == null) return null;
    return file.path;
  }

  @override
  Widget buildImage(BuildContext context, String key) {
    // We use custom "asset" scheme to distinguish asset images from other files.
    if (key.startsWith('asset://')) {
      final asset = AssetImage(key.replaceFirst('asset://', ''));
      return Image(image: asset);
    } else {
      // Otherwise assume this is a file stored locally on user's device.
      final file = File.fromUri(Uri.parse(key));
      final image = FileImage(file);
      return Image(image: image);
    }
  }
}