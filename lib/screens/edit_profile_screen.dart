import 'dart:convert';
import 'dart:io';

import 'package:blue/main.dart';
import 'package:blue/screens/profile_image_crop_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';

import './home.dart';
import '../models/user.dart';
import '../widgets/progress.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  File croppedImage;
  bool _websiteValid = true;
  getUser() async {
    setState(() {
      isLoading = true;
    });

 
    DocumentSnapshot doc = await usersRef.document(currentUser.id).get();
    user = User.fromDocument(doc);
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
      Uri.parse(websiteController.text.trim()).isAbsolute
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
      final Im.Image imageFile = Im.decodeImage(croppedImage.readAsBytesSync());
      final compressedImageFile = File('$path/img_$imageId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
      final Im.Image avatarFile = Im.copyResize(
          Im.decodeImage(croppedImage.readAsBytesSync()),
          width: 100);
      final compressedAvatarFile = File('$path/img_$avatarId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(avatarFile, quality: 85));
      StorageUploadTask imageUploadTask = storageRef
          .child("profile_$imageId.jpg")
          .putFile(compressedImageFile, StorageMetadata(contentType: 'jpg'));

      StorageUploadTask avatarUploadTask = storageRef
          .child("profile_$avatarId.jpg")
          .putFile(compressedAvatarFile, StorageMetadata(contentType: 'jpg'));
      StorageTaskSnapshot imageStorageSnap = await imageUploadTask.onComplete;
      StorageTaskSnapshot avatarStorageSnap = await avatarUploadTask.onComplete;
      String imageDownloadUrl = await imageStorageSnap.ref.getDownloadURL();
      String avatarDownloadUrl = await avatarStorageSnap.ref.getDownloadURL();
      profilePictureUrl = imageDownloadUrl;
      avatarUrl = avatarDownloadUrl;
      await usersRef.document(currentUser.id).updateData(
        {
          'displayName': displayNameController.text,
          'bio': bioController.text,
          'website': websiteController.text.trim(),
          'photoUrl': profilePictureUrl,
          'avatarUrl': avatarUrl,
        },
      );
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
      await usersRef.document(currentUser.id).updateData({
        'displayName': displayNameController.text,
        'bio': bioController.text,
        'website': websiteController.text.trim(),
      });
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
      'photoUrl':
          croppedImage == null ? currentUser.photoUrl : profilePictureUrl,
    };
    String currentUserString = json.encode(currentUserMap);
    print(currentUserMap);
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString('currentUser', currentUserString);
    Map currentUserMapGet = json.decode(preferences.get('currentUser')) ;
  currentUser = User(
    id: currentUserMapGet['id'],
    bio: currentUserMapGet['bio'],
    displayName: currentUserMapGet['displayName'],
    email: currentUserMapGet['email'],
    photoUrl: currentUserMapGet['photoUrl'],
    username: currentUserMapGet['username'],
    website: currentUserMapGet['website'],


  );
  }

  updateProfilePicture() async {
    File imageFile;
    var picker = ImagePicker();
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    imageFile = File(pickedFile.path);
    // if (imageFile != null) {
    //   setState(() {
    //     state = AppState.picked;
    //   });
    // }
    await Navigator.of(context)
        .pushNamed(ProfileImageCropScreen.routeName, arguments: imageFile)
        .then((value) {
      setState(() {
        croppedImage = value;
      });
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
                          top: 16.0,
                          bottom: 8.0,
                        ),
                        child: Container(
                          height: 100,
                          width: 100,
                          child: Center(
                            child: Stack(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 50.0,
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
                                    height: 100,
                                    width: 100,
                                    child: Icon(Icons.add_a_photo),
                                  ),
                                )
                              ],
                            ),
                          ),
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
