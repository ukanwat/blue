// Dart imports:
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:crypto/src/sha256.dart';
// Package imports:


import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_aws_s3_client/flutter_aws_s3_client.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http_client/http_client.dart' as http_client;

class FileStorage {
  static Future<String> upload(String folder, String fileName, File file,
      {String bucket}) async {
  

    print('uploaded');
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
      successful = false;
    }
    return successful;
  }
}

Future<String> s3Upload(
  String key,
  File content,
  String contentType,
) async {
  int contentLength = content.readAsBytesSync().lengthInBytes;

  Digest contentSha256 = sha256.convert(content.readAsBytesSync());

  String uriStr = 'https://auth.cloud.ovh.us' + '/' + key;
  http_client.Request request = http_client.Request('PUT', Uri.parse(uriStr),
      headers: http_client.Headers(), body: content);

  //   request.headers.add('x-amz-acl', 'public-read');
  // request.headers.add('Content-Length', contentLength);
  // request.headers.add('Content-Type', contentType);
  // signRequest(request, contentSha256: contentSha256);
  // http_client.Response response = await httpClient.send(request);
  // BytesBuilder builder = BytesBuilder(copy: false);
  // await response.body.forEach(builder.add);
  // String body = utf8.decode(builder.toBytes()); // Should be empty when OK
  // if (response.statusCode != 200) {
  //   throw ClientException(response.statusCode, response.reasonPhrase,
  //       response.headers.toSimpleMap(), body);
  // }
  // return response.headers[HttpHeaders.etagHeader].first;
}
