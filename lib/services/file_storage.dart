// Dart imports:
import 'dart:io';

// Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class FileStorage {
  static Future<String> upload(String folder, String fileName, File file,
      {String bucket}) async {
    Reference ref;
    if (bucket == null) {
      ref = FirebaseStorage.instance.ref().child(folder).child(fileName);
    } else {
      ref = FirebaseStorage.instanceFor(bucket: bucket)
          .ref()
          .child(folder)
          .child(fileName);
    }

    String url = '';
    await ref.putFile(file).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        url = value;
      });
    });
    return url;
  }

  static Future<String> uploadImage(String folder, File image,
      {String fileName, String bucket}) async {
    if (fileName == null) {
      fileName = Uuid().v4();
    }
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final Im.Image imageFile = Im.decodeImage(image.readAsBytesSync());
    final compressedImageFile = File('$path/img_$fileName.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    String url =
        await upload(folder, fileName, compressedImageFile, bucket: bucket);
    return url;
  }

  static Future<bool> delete(String url) async {
    bool successful = false;
    try {
      Reference storageReference = FirebaseStorage.instance.refFromURL(url);
      await storageReference.delete();
      successful = true;
    } catch (e) {
      print(e);
      successful = false;
    }
    return successful;
  }
}
