// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';

// Project imports:
import 'package:blue/widgets/header.dart';

class ProfileImageCropScreen extends StatefulWidget {
  static const routeName = 'profile-image-crop';
  @override
  _ProfileImageCropScreenState createState() => _ProfileImageCropScreenState();
}

class _ProfileImageCropScreenState extends State<ProfileImageCropScreen> {
  final cropKey = GlobalKey<CropState>();

  File _sample;
  File _lastCropped;

  @override
  Widget build(BuildContext context) {
    File _file = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: header(context,
            leadingButton: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actionButton: FlatButton(
                onPressed: () async {
                  final scale = cropKey.currentState.scale;
                  final area = cropKey.currentState.area;
                  if (area == null) {
                    // cannot crop, widget is not setup
                    return;
                  }

                  // scale up to use maximum possible number of pixels
                  // this will sample image in higher resolution to make cropped image larger
                  final sample = await ImageCrop.sampleImage(
                    file: _file,
                    preferredSize: (2000 / scale).round(),
                  );

                  final file = await ImageCrop.cropImage(
                    file: sample,
                    area: area,
                  );

                  debugPrint('$file');
                  Navigator.pop(context, file);
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
          height: MediaQuery.of(context).size.width,
          child: Crop.file(
            _file,
            key: cropKey,
            alwaysShowGrid: false,
            aspectRatio: 1,
            scale: 1,
            maximumScale: 1,
          ),
        ));
  }
}
