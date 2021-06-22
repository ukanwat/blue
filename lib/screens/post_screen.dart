// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

// Flutter imports:
import 'package:blue/widgets/banner_dialog.dart';
import 'package:blue/widgets/empty_dialog.dart';
import 'package:blue/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import '../services/hasura.dart';
import 'package:blurhash_dart/blurhash_dart.dart';
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
import '../services/boxes.dart';

int textLength = 0;
enum ContentInsertOptions { Device, Camera, Carousel }

enum ThumbContent { video, image, carousel, link, text, none }

class PostScreen extends StatefulWidget {
  static const routeName = '/post';
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  //limits
  int lvid = 1;
  int limg = 10;
  int ltxt = 750;
  int llnk = 5;
  //count
  int cvid = 0;
  int cimg = 0;
  int clnk = 0;
  int ctxt = 0;

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
  TextEditingController subtitleController = TextEditingController();
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
  String getBlurHash(File _image) {
    Uint8List fileData = _image.readAsBytesSync();
    Im.Image img = Im.decodeImage(fileData.toList());

    String blurHash = encodeBlurHash(
      img.getBytes(format: Im.Format.rgba),
      img.width,
      img.height,
    );
    return "\"$blurHash\"";
  }

  handleTakePhoto() async {
    File _cameraImage;
    var pickedFile = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: 576,
        maxWidth: 576,
        imageQuality: 75);
    _cameraImage = File(pickedFile.path);

    addImageContent(_cameraImage);
  }

  addImageContent(File _image) async {
    fileIndex++;
    double _aspectRatio;
    var decodedImage = await decodeImageFromList(_image.readAsBytesSync());
    _aspectRatio =
        decodedImage.width.toDouble() / decodedImage.height.toDouble();
    Map infoMap = {}; //
    infoMap['type'] = 'image'; //
    infoMap['aspectRatio'] = _aspectRatio; //

    String blurHash = getBlurHash(_image);
    infoMap['blurHash'] = blurHash; //
    contentsInfo[fileIndex] = infoMap; //
    setState(() {
      if (_image == null) {
        print('File is not available');
      } else {
        contentsData.add({
          'info': {
            'type': 'image',
            'aspectRatio': _aspectRatio,
            'blurHash': blurHash
          },
          'content': _image,
          'widget': imageDisplay(_image, fileIndex, _aspectRatio)
        });
        contents.add(imageDisplay(_image, fileIndex, _aspectRatio));
      }
    });
  }

  handleChooseImageFromGallery() async {
    File _galleryImage;
    var pickedFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 576,
        maxWidth: 576,
        imageQuality: 75);
    _galleryImage = File(pickedFile.path);
    addImageContent(_galleryImage);
  }

  handleTakeVideo() async {
    File _cameraVideo;
    var pickedFile = await ImagePicker.pickVideo(
      source: ImageSource.camera,
      maxDuration: Duration(minutes: 2),
    );
    _cameraVideo = File(pickedFile.path);
    addVideoContent(_cameraVideo);
  }

  addVideoContent(File _video) {
    VideoPlayerController _vidController =
        new VideoPlayerController.file(_video);
    print(_video.path);
    print(_video.uri);
    if (_vidController.value.duration.compareTo(Duration(minutes: 3)) > 0) {
      snackbar('video cannot be longer than 3 minutes', context);
      return;
    }
    fileIndex++;
    _videoPlayerController = _vidController
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
            'content': _video,
            'widget': Container(child: VideoDisplay(flickManager, false))
          });

          if (_videoPlayerController.value.isPlaying == true) {}
        });
      });
  }

  handleChooseVideoFromGallery() async {
    File _galleryVideo;
    var pickedFile = await ImagePicker.pickVideo(
        source: ImageSource.gallery, maxDuration: Duration(minutes: 2));
    _galleryVideo = File(pickedFile.path);
    addVideoContent(_galleryVideo);
  }

  List<Asset> resultList = List<Asset>();
  String error = 'No Error Dectected';
  Future<void> handleCreateCarousel() async {
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: limg - cimg,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
        ),
        materialOptions: MaterialOptions(
          actionBarColor: "#1EE682",
          actionBarTitle: "Stark",
          statusBarColor: "#1EE682",
          allViewTitle: "All Images",
          useDetailsView: true,
          selectCircleStrokeColor: "#000000",
        ),
      );
      if (resultList.length == 0) {
        return;
      }
    } on Exception catch (e) {
      error = e.toString(); //show error
      return;
    }

    if (!mounted) return;
    List carouselData = await getCarouselImages(resultList);

    List<File> carouselImages = carouselData[0];
    double _aspectRatio = carouselData[1];
    addCarouselContent(carouselImages, _aspectRatio);
  }

  addCarouselContent(List<File> carouselImages, double _aspectRatio) {
    fileIndex++;
    List<String> blurHashes = [];
    carouselImages.forEach((i) {
      blurHashes.add(getBlurHash(i));
    });
    setState(() {
      contentsData.add({
        'info': {
          'type': 'carousel',
          'aspectRatio': _aspectRatio,
          'blurHashes': blurHashes
        },
        'content': carouselImages,
        'widget':
            carouselDisplay(carouselImages, fileIndex, _aspectRatio, blurHashes)
      });
      contents.add(
          carouselDisplay(carouselImages, fileIndex, _aspectRatio, blurHashes));
    });
  }

  Future<File> compressImage(
    File file,
  ) async {
    imageId = Uuid().v4();
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$imageId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 30));
    return compressedImageFile;
  }

  Future<String> uploadImage(File file, {bool thumb}) async {
    //Upload Profile Photo
    String _url = await FileStorage.upload(
        '$postId', '${thumb == true ? 'thumbnail' : 'image'}_$imageId', file,
        bucket: 'user-posts');
    return _url;
  }

  Future<List<String>> uploadCarousel(List<File> files) async {
    List<String> downloadUrls = [];
    for (int i = 0; i < files.length; i++) {
      String _imageId = Uuid().v4();
      File file = await compressImage(
        files[i],
      );
      String _url = await FileStorage.upload(
          '$postId', 'carousel_$_imageId', file,
          bucket: 'user-posts');
      downloadUrls.add("\"$_url\"");
    }
    return downloadUrls;
  }

  Future<String> uploadVideo(dynamic mediaInfo) async {
    String _videoId = Uuid().v4();
    String _url = await FileStorage.upload(
        '$postId', 'video_$_videoId', mediaInfo.file,
        bucket: 'user-posts');
    return _url;
  }

  uploadPost(
      {Map<String, dynamic> contents,
      String title,
      Map<String, Map> contentsInfo,
      String topicName,
      String topicId,
      Map<int, String> tags}) async {
    List customContents = [];
    contents.forEach((key, value) {
      customContents.add(contentsInfo[key]);
      customContents[int.parse(key)]['data'] =
          contentsInfo[key]['type'] == 'carousel'
              ? "$value"
              : """\"$value\""""; //TODO
    });
    print(customContents);
    if (tags == {}) {
      tags = null;
    }
    await Hasura.insertPost(customContents, title,
        tags: tags,
        topicName: topicName,
        thumbUrl: thumbUrl,
        customUserId: customUserIdController.text,
        subtitle: subtitleController.text);
  }

  final TextEditingController customUserIdController = TextEditingController();

  String thumbUrl;
  ThumbContent _thumbContent = ThumbContent.none;
  int thumbIndex;
  handleSubmit(String topicName, Map<int, String> tags) async {
    setState(() {
      isUploading = true;
    });
    int x = 0;
    for (int i = 0; i < contentsData.length; i++) {
      if (contentsData[i]['info']['type'] == 'null') {
      } else if (contentsData[i]['info']['type'] == 'link') {
        if (_thumbContent.index > 3) {
          thumbIndex = i;
          _thumbContent = ThumbContent.link;
        }
        firestoreContents['$x'] = contentsData[i]['content'].text;
        firestoreContentsInfo['$x'] = contentsData[i]['info'];
        x++;
      } else if (contentsData[i]['info']['type'] == 'text') {
        if (_thumbContent.index > 4) {
          thumbIndex = i;
          _thumbContent = ThumbContent.text;
        }
        firestoreContents['$x'] = contentsData[i]['content'].text;
        firestoreContentsInfo['$x'] = contentsData[i]['info'];
        x++;
      } else if (contentsData[i]['info']['type'] == 'image') {
        if (_thumbContent.index > 1) {
          thumbIndex = i;
          _thumbContent = ThumbContent.image;
        }
        File imageFile = await compressImage(contentsData[i]['content']);
        String mediaUrl = await uploadImage(imageFile);
        firestoreContents['$x'] = mediaUrl;
        firestoreContentsInfo['$x'] = contentsData[i]['info'];
        x++;
      } else if (contentsData[i]['info']['type'] == 'video') {
        if (_thumbContent.index > 0) {
          thumbIndex = i;
          _thumbContent = ThumbContent.video;
        }

        MediaInfo mediaInfo = await VideoCompress.compressVideo(
          contentsData[i]['content'].path,
          quality: VideoQuality.MediumQuality,
          deleteOrigin: false, // It's false by default
          frameRate: 24,
          includeAudio: true,
        );

        String videoId = Uuid().v4();
        String vUrl = await FileStorage.upload(
            'post', 'video_$videoId.mp4', mediaInfo.file);
        final thumbnail = await VideoCompress.getFileThumbnail(
            contentsData[i]['content'].path,
            quality: 75,
            position: -1);
        String tUrl = await FileStorage.uploadImage('post', thumbnail,
            fileName: 'thumb_$videoId');
        Map _videoData = {'thumbUrl': tUrl, 'videoUrl': vUrl};
        // Map _videoData = await VideoProcessing().processVideo(contentsData[i]['content'],postId);
        firestoreContents['$x'] = _videoData['videoUrl'];
        contentsData[i]['info']['thumbUrl'] = "\"${_videoData['thumbUrl']}\"";
        firestoreContentsInfo['$x'] = contentsData[i]['info'];
        x++;
      } else if (contentsData[i]['info']['type'] == 'carousel') {
        if (_thumbContent.index > 2) {
          thumbIndex = i;
          _thumbContent = ThumbContent.carousel;
        }

        List<String> mediaUrl =
            await uploadCarousel(contentsData[i]['content']);
        firestoreContents['$x'] = mediaUrl;
        firestoreContentsInfo['$x'] = contentsData[i]['info'];
        x++;
      }
    }

    File thumbImg;
    print('tindex: $thumbIndex ');
    if (_thumbContent == ThumbContent.carousel) {
      thumbImg = contentsData[thumbIndex]['content'][0];
    } else if (_thumbContent == ThumbContent.image) {
      thumbImg = contentsData[thumbIndex]['content'];
    } else if (_thumbContent == ThumbContent.link) {
      thumbImg = null;
    } else if (_thumbContent == ThumbContent.text) {
      thumbImg = null;
    } else if (_thumbContent == ThumbContent.video) {
      thumbImg = await VideoCompress.getFileThumbnail(
          contentsData[thumbIndex]['content'].path);
    }

    if (thumbImg != null) {
      String id = Uuid().v4();
      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;
      Im.Image imageFile = Im.decodeImage(thumbImg.readAsBytesSync());
      imageFile = Im.copyResizeCropSquare(imageFile, 270);
      // copyResize(imageFile, width: 270, height: 270,);
      final compressedImageFile = File('$path/img_$id.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));

      thumbUrl = await uploadImage(compressedImageFile, thumb: true);
    }

    print("doc:$topicName");
    await uploadPost(
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
    return TextDisplayWidget(textController, textFocusNode, () {
      int length = 0;
      for (int i = 0; i < contentsData.length; i++) {
        if (contentsData[i]['info']['type'] == 'text') {
          length = length + contentsData[i]['content'].text.length;
        }
      }
      textLength = length;
    });
    // Container(
    // padding: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 2),
    // child: TextFormField(
    //   controller: textController,
    //   focusNode: textFocusNode,
    //   keyboardType: TextInputType.multiline,
    //   maxLength: ltxt - ctxt,
    //   decoration: InputDecoration(
    //       counter: Container(),
    //       hintText: 'Write Something...',
    //       border: InputBorder.none),
    //   maxLines: null,
    //   onTap: () {
    //     if (editingText = false) {
    //       setState(() {
    //         editingText = true;
    //         currentTextController = textController;
    //       });
    //     }
    //   },
    // ));
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
    _url = linkController.text.toLowerCase().replaceAll(new RegExp(r"\s+"), "");
    if (!(_url.startsWith(
          'http://',
        ) ||
        _url.startsWith(
          'https://',
        ))) {
      _url = 'https://$_url';
    }

    print(_url);
    try {
      response = await head(Uri.parse(_url));
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

  Container carouselDisplay(List<File> images, int index, double aspectRatio,
      List<String> blurHashes) {
    Map infoMap = {};
    infoMap['type'] = 'carousel';
    infoMap['aspectRatio'] = aspectRatio;
    infoMap['blurHashes'] = blurHashes;
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
    ctxt = 0;
    _videoPlayerController?.dispose();
    flickManager?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    int _postId = ModalRoute.of(context).settings.arguments;
    if (_postId != null) {
      var _postData = Boxes.draftBox.values.elementAt(_postId);
      setState(() {
        _postData['contentsData'].forEach((data) {
          switch (data['info']['type']) {
            case 'text':
              TextEditingController textController =
                  TextEditingController(text: data['content']);
              FocusNode textFocusNode = FocusNode();
              setState(() {
                textControllers.add(textController);
                textFocusNodes.add(textFocusNode);
                fileIndex++;
                contentsData.add({
                  'info': {'type': 'text'},
                  'content': textController,
                  'widget':
                      textDisplay(textController, fileIndex, textFocusNode)
                });
                contents
                    .add(textDisplay(textController, fileIndex, textFocusNode));
              });
              break;
            case 'link':
              TextEditingController linkController =
                  TextEditingController(text: data['content']);
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
    cimg = 0;
    cvid = 0;
    ctxt = 0;
    clnk = 0;
    List<Widget> _contents = [];
    // draftBox.deleteAll([0,1]);

    for (int i = 0; i < contentsData.length; i++) {
      if (contentsData[i]['info']['type'] == 'text') {
        if (contentsData[i]['content'].text.length == 0) {
          if (contentsData.length > i + 1) {
            contentsData[i] = null;
          } else {
            _contents.add(Stack(
              alignment: Alignment.topRight,
              children: [
                contentsData[i]['widget'],
                GestureDetector(
                    onTap: () {
                      showContentSettingsSheet(i + 1);
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        child: Icon(
                          FluentIcons.settings_16_filled,
                          size: 18,
                          color: Colors.grey,
                        ))),
              ],
            ));
          }
        } else {
          _contents.add(Stack(
            alignment: Alignment.topRight,
            children: [
              contentsData[i]['widget'],
              GestureDetector(
                  onTap: () {
                    showContentSettingsSheet(i + 1);
                  },
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      child: Icon(
                        FluentIcons.settings_16_filled,
                        size: 18,
                        color: Colors.grey,
                      ))),
            ],
          ));
        }
      } else {
        _contents.add(GestureDetector(
            onLongPress: () {
              showContentSettingsSheet(i + 1);
            },
            child: contentsData[i]['widget']));
      }
      print('content data: $contentsData');
      print(contentsData[i]);
      if (contentsData[i] != null) {
        switch (contentsData[i]['info']['type']) {
          case 'image':
            cimg++;
            break;
          case 'video':
            cvid++;
            break;
          case 'carousel':
            cimg = cimg + contentsData[i]['content'].length;
            break;
          case 'text':
            ctxt = ctxt + contentsData[i]['content'].text.length;
            break;
          case 'link':
            clnk++;
            break;
          default:
        }
      }
    }
    for (int i = 0; i < contentsData.length; i++) {
      if (contentsData[i] == null) {
        contentsData.removeAt(i);
      }
    }
    print('cimg: $cimg');
    print(Boxes.draftBox.values);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
          elevation: 0.5,
          leading: IconButton(
              icon: Icon(
                Icons.clear,
              ),
              onPressed: () {
                if (isDrafted || contentsData.length == 0) {
                  Navigator.pop(context);
                } else {
                  List<dynamic> _checkContentsData = contentsData;
                  bool containsVideo = false;
                  _checkContentsData.forEach((d) {
                    if (d['info']['type'] == 'video') {
                      containsVideo = true;
                    }
                  });

                  showDialog(
                    context: context,
                    builder: (BuildContext context) => ShowDialog(
                      title: "Save as Draft",
                      description: containsVideo
                          ? "Drafts currently do not support video content. Do you want to save your work as Draft without the video?"
                          : "Do you want to save your work as Draft?",
                      rightButtonText: "Save Draft",
                      leftButtonText: "Cancel",
                      rightButtonFunction: () async {
                        List<dynamic> _modifiedContentsData = contentsData;
                        int _i = 0;
                        _modifiedContentsData.forEach((d) {
                          if (d['info']['type'] == 'video') {
                            _modifiedContentsData.removeAt(_i);
                          } else
                            _i++;
                        });
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
                            // case 'video':
                            //   // print('its video draft content');
                            //   // final _fileName = Path.basename(
                            //   //     _modifiedContentsData[i]['content'].path);
                            //   // String _path =
                            //   //     appDocDir.path + '/posts/$postId/$_fileName';
                            //   // await _modifiedContentsData[i]['content']
                            //   //     .copy(_path);
                            //   // _modifiedContentsData[i]['content'] = _path;
                            //   break;
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

                        Boxes.draftBox.add({
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
                      if (cimg >= limg) {
                        showLimits(context);
                        return;
                      }
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
                      if (cvid >= lvid) {
                        showLimits(context);
                        return;
                      }
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
                          if (ctxt >= ltxt) {
                            showLimits(context);
                            return;
                          }
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
                        if (clnk >= llnk) {
                          showLimits(context);
                          return;
                        }
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: CircleAvatar(
                //     maxRadius: 20,
                //     backgroundImage: CachedNetworkImageProvider(Boxes
                //             .currentUserBox
                //             .get('avatar_url') ??
                //         "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744"),
                //   ),
                // ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        color: Theme.of(context).cardColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                'TITLE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        width: double.infinity,
                        child: TextField(
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          minLines: 1,
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: "Some Title...",
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(0.8)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!kReleaseMode)
                  Container(
                    width: 50,
                    child: TextField(
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      minLines: 1,
                      controller: customUserIdController,
                      decoration: InputDecoration(
                        hintText: "id",
                        hintStyle: TextStyle(
                            color: Theme.of(context)
                                .iconTheme
                                .color
                                .withOpacity(0.8)),
                        border: InputBorder.none,
                      ),
                    ),
                  )
              ],
            ),
            Container(
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      'SUBTITLE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              width: double.infinity,
              child: TextField(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                maxLines: 1,
                minLines: 1,
                controller: subtitleController,
                decoration: InputDecoration(
                  hintText: "(Optional)",
                  hintStyle: TextStyle(
                      color:
                          Theme.of(context).iconTheme.color.withOpacity(0.8)),
                  border: InputBorder.none,
                ),
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              height: 1,
              thickness: 1,
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
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.transparent),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          FluentIcons.collections_add_24_regular,
                          size: 65,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: Text(
                        'Add Content from the Tab',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context)
                                .iconTheme
                                .color
                                .withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            builder: (context) {
                              return BannerDialog(
                                  'Community Guidelines',
                                  """Section 1: Illegal Content

(A) Underage Sexual Content
Posting underage sexual content will result in an immediate ban. To be on the safe side, this also applies to content that is "ambiguous". Don't do it.

(B) Doxxing / Physical Threats
You may not post any content or actions that threaten physical harm or otherwise incite violence.

(C) Copyrighted Content
We have neither the resources nor the inclination to determine if the contents of your post is properly licensed. We will only take proactive action to remove content that is obviously infringing on someone's copyright. Other than that, we will respond on a case-by-case basic to any complaints we receive from copyright holders under DMCA.

Section 2: Explicit Content

(A) Violence / Gore
Please don't post overly graphic/violent/disturbing images or video.

(B) NSFW Content
Please don't post pornographic material. We don't have the resources to moderate it at the current time.

Section 3: Spam

(A) Phishing / Deception
Impersonating someone, or otherwise attempting to materially defraud other users will result in a ban.

(B) Disruptive Content
Repeatedly posting the same content, posting something incomprehensible (like just mashing your keyboard), deliberately miscategorizing posts, or repeatedly posting advertisements or other low-effort content without any context or explanation is not allowed. The general principle is that "bad faith" posts will be removed so they don't distract from valuable content.

""",
                                  true);
                            },
                            context: context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          'Read Community Guidelines',
                          style: TextStyle(
                              fontFamily: 'Stark Sans',
                              color: Colors.blue,
                              fontWeight: FontWeight.w300,
                              fontSize: 11),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
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

  limitIconBox(IconData icon, String s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          Text(
            s,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11),
          )
        ],
      ),
    );
  }

  showLimits(BuildContext context) {
    snackbar("You've reached the limit.", context, seeMore: () {
      showDialog(
          context: context,
          builder: (context) {
            return EmptyDialog(
              Container(
                height: 90,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Post Limits',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          limitIconBox(Icons.text_fields, '1000\nchars'),
                          SizedBox(
                            width: 10,
                          ),
                          limitIconBox(
                              FluentIcons.image_16_filled, '10\nimages'),
                          SizedBox(
                            width: 10,
                          ),
                          limitIconBox(FluentIcons.link_16_filled, '5\nlinks'),
                          SizedBox(
                            width: 10,
                          ),
                          limitIconBox(FluentIcons.video_16_filled, '1\nvideo')
                        ],
                      )
                    ]),
              ),
              noHorizontalPadding: true,
            );
            // BannerDialog(
            //     'Post Limits',
            //     'Post is limited to 500 characters, 10 images, 5 links and 1 Video.',
            //     true);
          });
    });
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
                    border: i == functions.length - 1
                        ? null
                        : Border(
                            bottom:
                                BorderSide(width: 0.3, color: Colors.grey))),
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

typedef TextLengthCallback = void Function();

class TextDisplayWidget extends StatefulWidget {
  TextDisplayWidget(this.textController, this.textFocusNode, this.onTextSelect);
  final TextEditingController textController;

  final FocusNode textFocusNode;
  final TextLengthCallback onTextSelect;
  @override
  _TextDisplayWidgetState createState() => _TextDisplayWidgetState();
}

class _TextDisplayWidgetState extends State<TextDisplayWidget> {
  limitIconBox(IconData icon, String s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          Text(
            s,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11),
          )
        ],
      ),
    );
  }

  showLimits(BuildContext context) {
    snackbar("You've reached the limit.", context, seeMore: () {
      showDialog(
          context: context,
          builder: (context) {
            return EmptyDialog(
              Container(
                height: 90,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Post Limits',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          limitIconBox(Icons.text_fields, '1000\nchars'),
                          SizedBox(
                            width: 10,
                          ),
                          limitIconBox(
                              FluentIcons.image_16_filled, '10\nimages'),
                          SizedBox(
                            width: 10,
                          ),
                          limitIconBox(FluentIcons.link_16_filled, '5\nlinks'),
                          SizedBox(
                            width: 10,
                          ),
                          limitIconBox(FluentIcons.video_16_filled, '1\nvideo')
                        ],
                      )
                    ]),
              ),
              noHorizontalPadding: true,
            );
            // BannerDialog(
            //     'Post Limits',
            //     'Post is limited to 500 characters, 10 images, 5 links and 1 Video.',
            //     true);
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('ddd ${500 + widget.textController.text.length - textLength}');
    widget.onTextSelect();
    if ((500 + widget.textController.text.length - textLength) < 0 &&
        widget.textController.text.length == 0) {
      showLimits(context);
      return Container();
    }
    return Container(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 2),
        child: TextFormField(
          controller: widget.textController,
          focusNode: widget.textFocusNode,
          keyboardType: TextInputType.multiline,
          maxLength: 500 + widget.textController.text.length - textLength,
          decoration: InputDecoration(
              counter: Container(),
              hintText: 'Something...',
              border: InputBorder.none),
          maxLines: null,
          onChanged: (c) {
            if (500 + widget.textController.text.length - textLength == 0) {}
          },
          onTap: () {
            setState(() {
              widget.onTextSelect();
            });
          },
        ));
  }
}
