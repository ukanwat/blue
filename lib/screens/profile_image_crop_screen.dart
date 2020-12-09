import 'dart:io';
import 'package:blue/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:simple_image_crop/simple_image_crop.dart';

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
      leadingButton: IconButton(icon: Icon(Icons.clear), onPressed: () => Navigator.of(context),
      color: Colors.black,
      
      ),actionButton: FlatButton(onPressed:  () async {
    final crop = cropKey.currentState;
    final croppedFile =
        await crop.cropCompleted(imageFile, pictureQuality: 900);
    Navigator.pop(context,croppedFile);
  }, child: Text('Done'
  
  ,style: TextStyle(fontSize: 18,
    color: Colors.blue
  ),
  )),
          title: Text(
            'Crop',
            style: TextStyle(
              color: Colors.black
            ),
          )),
          body: Container(
      color: Colors.black,
      child: ImgCrop(maximumScale: 1,
        key: cropKey,
        chipRadius: MediaQuery.of(context).size.width/2 - 12,  // crop area radius
        chipShape: 'circle',
         // crop type "circle" or "rect"
        image: FileImage(imageFile),
      ),)
    );
  }
}
