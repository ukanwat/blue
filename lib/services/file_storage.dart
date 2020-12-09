import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FileStorage {
  static Future<String> upload(String folder, String fileName, File file) async {
    Reference ref =
        FirebaseStorage.instance.ref().child(folder).child(fileName);
    String url = '';
    await ref.putFile(file).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        url = value;
      });
    });
    return url;
  }
    static Future<bool> delete(String url) async {
      bool successful = false;
      try{
    Reference storageReference = FirebaseStorage.instance.refFromURL(url);
    await storageReference.delete();
    successful = true;
      }catch(e){
        print(e);
        successful = false;
      }
    return successful;
  }
}
