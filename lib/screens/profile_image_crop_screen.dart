// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import '../packages/simple_image_crop.dart/simpleCrop.dart';

// Project imports:
import 'package:blue/widgets/header.dart';

class ProfileImageCropScreen extends StatefulWidget {
  static const routeName = 'profile-image-crop';
  @override
  _ProfileImageCropScreenState createState() => _ProfileImageCropScreenState();
}

class _ProfileImageCropScreenState extends State<ProfileImageCropScreen> {
  final cropKey = GlobalKey<ImgCropState>();
  @override
  Widget build(BuildContext context) {
    File imageFile = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: header(context,
          leadingButton: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => Navigator.of(context),
          ),
          actionButton: FlatButton(
              onPressed: () async {
                final crop = cropKey.currentState;
                final croppedFile = await crop.cropCompleted(
                  imageFile,
                  preferredSize: 500,
                );
                Navigator.pop(context, croppedFile);
              },
              child: Text(
                'Done',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              )),
          title: Text(
            'Crop',
            style: TextStyle(),
          )),
      body: Container(
        margin: EdgeInsets.only(bottom: 100),
        height: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: ImgCrop(
          maximumScale: 1, chipShape: ChipShape.circle, chipRatio: 1,

          key: cropKey,
          chipRadius:
              MediaQuery.of(context).size.width / 2 - 12, // crop area radius

          // crop type "circle" or "rect"
          image: FileImage(imageFile),
        ),
      ),
    );
  }
}
