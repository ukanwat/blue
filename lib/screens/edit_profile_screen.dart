// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:blue/services/boxes.dart';
import 'package:blue/services/boxes.dart';
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
  TextEditingController bioController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;
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

    DocumentSnapshot doc = await usersRef.doc(currentUser.id).get();
    user = User.fromDocument(doc.data());
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
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
    bioController.dispose();
    websiteController.dispose();
  }

  updateProfileData() async {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 300
          ? _bioValid = false
          : _bioValid = true;
      Uri.parse(websiteController.text.trim()).isAbsolute //TODO
          ? _websiteValid = true
          : _websiteValid = false;
    });
    if (croppedImage != null &&
        _displayNameValid &&
        _bioValid &&
        _websiteValid) {
      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;
      String avatarId = Uuid().v4();
      String imageId = Uuid().v4();
      if (headerImage != null) {
        String headerId = Uuid().v4();
        final Im.Image headerFile =
            Im.decodeImage(headerImage.readAsBytesSync());

        final compressedHeaderFile = File('$path/img_$headerId.jpg')
          ..writeAsBytesSync(Im.encodeJpg(headerFile, quality: 85));
         headerUrl =   await FileStorage.upload('profile', headerId,compressedHeaderFile);
      }

      final Im.Image imageFile = Im.decodeImage(croppedImage.readAsBytesSync());

      final compressedImageFile = File('$path/img_$imageId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
      final Im.Image avatarFile = Im.copyResize(
          Im.decodeImage(croppedImage.readAsBytesSync()),
          width: 100);
      final compressedAvatarFile = File('$path/img_$avatarId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(avatarFile, quality: 85));
    String imageDownloadUrl = await FileStorage.upload('profile', "photo_$imageId.jpg", compressedImageFile);
     String avatarDownloadUrl = await FileStorage.upload('profile', "avatar_$avatarId.jpg", compressedAvatarFile);
      profilePictureUrl = imageDownloadUrl;
      avatarUrl = avatarDownloadUrl;
      if (headerUrl == null) {
        await usersRef.doc(currentUser.id).update(
          {
            'displayName': displayNameController.text,
            'bio': bioController.text,
            'website': websiteController.text.trim(),
            'photoUrl': profilePictureUrl,
            'avatarUrl': avatarUrl,
          },
        );
      } else {
        await usersRef.doc(currentUser.id).update(
          {
            'displayName': displayNameController.text,
            'bio': bioController.text,
            'website': websiteController.text.trim(),
            'photoUrl': profilePictureUrl,
            'avatarUrl': avatarUrl,
            'headerUrl': headerUrl,
          },
        );
      }

      SnackBar snackbar = SnackBar(
        content: Text('Profile Updated!'),
      );

      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
    if (croppedImage == null &&
        _displayNameValid &&
        _bioValid &&
        _websiteValid) {
      if (headerImage != null) {
        final tempDir = await getTemporaryDirectory();
        final path = tempDir.path;
        String headerId = Uuid().v4();
        final Im.Image headerFile =
            Im.decodeImage(headerImage.readAsBytesSync());

        final compressedHeaderFile = File('$path/img_$headerId.jpg')
          ..writeAsBytesSync(Im.encodeJpg(headerFile, quality: 85));
      headerUrl = await FileStorage.upload('profile', "header_$headerId.jpg", compressedHeaderFile);

      }
      if (headerUrl == null) {
        await usersRef.doc(currentUser.id).update({
          'displayName': displayNameController.text,
          'bio': bioController.text,
          'website': websiteController.text.trim(),
        });
      } else {
        await usersRef.doc(currentUser.id).update({
          'displayName': displayNameController.text,
          'bio': bioController.text,
          'website': websiteController.text.trim(),
          'headerUrl': headerUrl,
        });
      }

      SnackBar snackbar = SnackBar(
        content: Text('Profile Updated!'),
      );

      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
    Map currentUserMap = {
      'id': currentUser.id,
      'username': currentUser.username,
      'email': user.email,
      'displayName': displayNameController.text,
      'bio': bioController.text,
      'website': websiteController.text.trim(),
      'photoUrl': croppedImage == null
          ? currentUser.photoUrl
          : profilePictureUrl, //TODO
      'headerUrl': headerUrl == null ? currentUser.headerUrl : headerUrl,
    };
    Boxes.currentUserBox.putAll(currentUserMap );

    Map currentUserMapGet =  Boxes.currentUserBox.toMap();
    currentUser = User(
        id: currentUserMapGet['id'],
        bio: currentUserMapGet['bio'],
        displayName: currentUserMapGet['displayName'],
        email: currentUserMapGet['email'],
        photoUrl: currentUserMapGet['photoUrl'],
        username: currentUserMapGet['username'],
        website: currentUserMapGet['website'],
        headerUrl: currentUserMapGet['headerUrl']);
  }

  updateProfilePicture() async {
    File imageFile;
    var picker = ImagePicker();
    var pickedFile = await picker.getImage(
        source: ImageSource.gallery, maxHeight: 500, maxWidth: 1000);
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
        await picker.getImage(source: ImageSource.gallery, imageQuality: 85);
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

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          keyboardType: TextInputType.multiline,
          maxLength: 300,
          maxLines: 8,
          minLines: 1,
          decoration: InputDecoration(
              hintText: "Update Bio",
              errorText: _bioValid ? null : "Bio is too long"),
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
              errorText:
                  _websiteValid ? null : "Please enter a valid website url"),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print(currentUser.headerUrl);
    print('thfthfthfh');
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
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
              Icons.save,
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
                        child: Stack(
                          overflow: Overflow.visible,
                          children: <Widget>[
                            if (headerImage == null)
                              GestureDetector(
                                  onTap: updateHeaderPicture,
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        child: currentUser.headerUrl == null
                                            ? Container(
                                                height: 140,
                                                color: Colors.grey,
                                                width: double.infinity,
                                              )
                                            : Container(
                                                height: 140,
                                                child: cachedNetworkImage(
                                                    context,
                                                    currentUser.headerUrl),
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
                                                user.photoUrl,
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
                                          child: Icon(Icons.add_a_photo),
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
                            buildBioField(),
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
