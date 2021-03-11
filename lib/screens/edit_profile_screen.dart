// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:blue/services/boxes.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/hasura.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/profile_image_crop_screen.dart';
import 'package:blue/widgets/custom_image.dart';
import '../services/file_storage.dart';
import '../widgets/progress.dart';
import './home.dart';

import '../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool userLoaded = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _aboutValid = true;
  String profilePictureUrl;
  String avatarUrl;
  String headerUrl;
  File croppedImage;
  File headerImage;
  bool _websiteValid = true;
  getUser() async {
    setState(() {
      isLoading = true;
    });

    Map doc = await Hasura.getUser(self: true);
    user = User.fromDocument(doc['data']['users_by_pk']);
    print(user.headerUrl);
    displayNameController.text = user.name;
    aboutController.text = user.about;
    websiteController.text = user.website;

    setState(() {
      isLoading = false;
    });
  }

 @override
  void didChangeDependencies() {
    if (!userLoaded) {
  getUser();
 
      userLoaded = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    displayNameController.dispose();
    aboutController.dispose();
    websiteController.dispose();
  }

  updateProfileData() async {
    progressOverlay(context).show();
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      aboutController.text.trim().length > 300
          ? _aboutValid = false
          : _aboutValid = true;
      Uri.parse(websiteController.text.trim()).isAbsolute || websiteController.text == null||websiteController.text == ''//TODO
          ? _websiteValid = true
          : _websiteValid = false;
    });
    if (croppedImage != null &&
        _displayNameValid &&
        _aboutValid &&
        _websiteValid) {
      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;
     
      String avatarId = Uuid().v4();
      String imageId = Uuid().v4();
      String imageDownloadUrl =  await FileStorage.uploadImage('profile',croppedImage,fileName: 'profile_$imageId');
    
      final Im.Image avatarFile = Im.copyResize(
          Im.decodeImage(croppedImage.readAsBytesSync()),
          width: 100);
      final compressedAvatarFile = File('$path/img_$avatarId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(avatarFile, quality: 85));
      String avatarDownloadUrl = await FileStorage.uploadImage(
          'profile',  compressedAvatarFile,fileName:"avatar_$avatarId.jpg");
      profilePictureUrl = imageDownloadUrl;
      avatarUrl = avatarDownloadUrl;
      if (headerUrl == null) {
       await Hasura.updateUser(
          name: displayNameController.text,
          about: aboutController.text,
          website: websiteController.text.trim(),
          photoUrl: profilePictureUrl,
          avatarUrl: avatarUrl
        );
      } else {
        
          await Hasura.updateUser(
          name: displayNameController.text,
          about: aboutController.text,
          website: websiteController.text.trim(),
          photoUrl: profilePictureUrl,
          avatarUrl: avatarUrl,
          headerUrl: headerUrl
        );
      }

       progressOverlay(context).dismiss();
      Navigator.pop(context);
       snackbar('Profile Updated!', context);
    }
    if (croppedImage == null &&
        _displayNameValid &&
        _aboutValid&&
        _websiteValid ) {
      if (headerImage != null) {
        String headerId = Uuid().v4();
        headerUrl = await FileStorage.uploadImage(
            'profile',  headerImage,fileName:"header_$headerId.jpg",);
        
      }
      if (headerUrl == null) {
        
           await Hasura.updateUser(
          name: displayNameController.text,
          about: aboutController.text,
          website: websiteController.text.trim(),
        );
      } else {
      
           await Hasura.updateUser(
          name: displayNameController.text,
          about: aboutController.text,
          website: websiteController.text.trim(),
          headerUrl: headerUrl
        );
      }

      
       snackbar('Profile Updated!', context);
         progressOverlay(context).dismiss();
       Navigator.pop(context);
     
    }
    Map currentUserMap = {
      'id': currentUser.id,
      'username': currentUser.username,
      'email': user.email,
      'displayName': displayNameController.text,
      'about': aboutController.text,
      'website': websiteController.text.trim(),
      'photoUrl': croppedImage == null
          ? user.photoUrl
          : profilePictureUrl, //TODO
      'headerUrl': headerUrl == null ? user.headerUrl : headerUrl,
    };
    Boxes.currentUserBox.putAll(currentUserMap);
    Map currentUserMapGet = Boxes.currentUserBox.toMap();
    currentUser = User(
        id: currentUserMapGet['id'],
        about: currentUserMapGet['about'],
        name: currentUserMapGet['displayName'],
        email: currentUserMapGet['email'],
        photoUrl: currentUserMapGet['photoUrl'],
        username: currentUserMapGet['username'],
        website: currentUserMapGet['website'],
        headerUrl: currentUserMapGet['headerUrl']);
          Navigator.pop(context);
     
  }

  updateProfilePicture() async {
    File imageFile;
    var picker = ImagePicker();
    var pickedFile = await picker.getImage(
        source: ImageSource.gallery, maxHeight: 270, maxWidth: 270);
    if (pickedFile == null) return;
    imageFile = File(pickedFile.path);

    await Navigator.of(context)
        .pushNamed(ProfileImageCropScreen.routeName, arguments: imageFile)
        .then((value) {
      if (value == null) return;
      setState(() {
        croppedImage = value;
      });
    });
  }

  updateHeaderPicture() async {
    File headerFile;
    var picker = ImagePicker();
    var pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 75,maxHeight: 320,maxWidth:720);
    if (pickedFile == null) return;
    headerFile = File(pickedFile.path);

    if (headerFile == null) return;
    setState(() {
      headerImage = headerFile;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
              hintText: "Update Display Name",
              errorText:
                  _displayNameValid ? null : "Display Name is too short"),
        )
      ],
    );
  }

  Column buildAboutField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "About",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: aboutController,
          keyboardType: TextInputType.multiline,
          maxLength: 300,
          maxLines: 8,
          minLines: 1,
          decoration: InputDecoration(
              hintText: "Update About",
              errorText: _aboutValid ? null : "About text is too long"),
        )
      ],
    );
  }

  Column buildWebsiteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Website",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: websiteController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
              hintText: "Website Address",
              errorText:  _websiteValid ? null : "Invalid url",
              
              ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 1,
        title: Text(
          "Edit Profile",
          
          style: TextStyle(),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: updateProfileData,
            icon: Icon(
            FluentIcons.save_24_regular,
              size: 30.0,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 60.0,
                        ),
                        child: Stack(clipBehavior: Clip.none,
                          children: <Widget>[
                            if (headerImage == null)
                              GestureDetector(
                                  onTap: updateHeaderPicture,
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        child: user.headerUrl == null
                                            ? Container(
                                                height: 140,
                                                color: Colors.grey,
                                                width: double.infinity,
                                              )
                                            : Container(
                                                height: 140,
                                                child: cachedNetworkImage(
                                                    context,
                                                    user.headerUrl),
                                                width: double.infinity,
                                              ),
                                      ),
                                      Positioned.fill(
                                          child: Container(
                                        width: double.infinity,
                                        height: 140,
                                        color:
                                            Colors.grey[900].withOpacity(0.6),
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              top: 20,
                                              bottom: 75,
                                              left: 100,
                                              right: 100),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 3)),
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                              child: Text(
                                            'Add Header Image',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          )),
                                        ),
                                      ))
                                    ],
                                  ))
                            else
                              GestureDetector(
                                  onTap: updateHeaderPicture,
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        height: 140,
                                        child: Image.file(
                                          headerImage,
                                          fit: BoxFit.cover,
                                        ),
                                        width: double.infinity,
                                      ),
                                      Positioned.fill(
                                          child: Container(
                                        width: double.infinity,
                                        height: 140,
                                        color:
                                            Colors.grey[900].withOpacity(0.6),
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              top: 20,
                                              bottom: 75,
                                              left: 100,
                                              right: 100),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 3)),
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                              child: Text(
                                            'Replace Header Image',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          )),
                                        ),
                                      ))
                                    ],
                                  )),
                            Positioned(
                              top: 80,
                              left: MediaQuery.of(context).size.width / 2 - 60,
                              child: Container(
                                height: 120,
                                width: 120,
                                child: Center(
                                  child: Stack(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 60.0,
                                        backgroundImage: croppedImage != null
                                            ? FileImage(croppedImage)
                                            : CachedNetworkImageProvider(
                                                user.avatarUrl??"https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/placeholder_avatar.jpg?alt=media&token=cab69e87-94a0-4f72-bafa-0cd5a0124744",
                                              ),
                                      ),
                                      InkWell(
                                        onTap: updateProfilePicture,
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromRGBO(0, 0, 0, 0.1),
                                          ),
                                          height: 120,
                                          width: 120,
                                          child: Icon(FluentIcons.camera_add_24_filled,color: Colors.white,),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildDisplayNameField(),
                            buildAboutField(),
                            buildWebsiteField(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
