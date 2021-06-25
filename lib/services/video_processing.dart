// // Dart imports:
// import 'dart:io';

// // Package imports:
// import 'package:blue/services/file_storage.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
// class VideoProcessing {
//   static final FlutterFFmpeg _encoder = FlutterFFmpeg();
//   static final FlutterFFprobe _probe = FlutterFFprobe();
//   // static final FlutterFFmpegConfig _config = FlutterFFmpegConfig();

//   static Future<String> getThumb(videoPath, width, height) async {
//     assert(File(videoPath).existsSync());

//     final String outPath = '$videoPath.jpg';
//     final arguments =
//         '-y -i $videoPath -vframes 1 -an -s ${width}x$height -ss 1 $outPath';

//     final int rc = await _encoder.execute(arguments);
//     assert(rc == 0);
//     assert(File(outPath).existsSync());

//     return outPath;
//   }

//   static Future<Map<dynamic, dynamic>> getMediaInformation(String path) async {
//     return await _probe.getMediaInformation(path);
//   }

//   static double getAspectRatio(Map<dynamic, dynamic> info) {
//     final int width = info['streams'][0]['width'];
//     final int height = info['streams'][0]['height'];
//     final double aspect = height / width;
//     return aspect;
//   }

//   static int getDuration(Map<dynamic, dynamic> info) {
//     return info['duration'];
//   }

//   void updatePlaylistUrls(File file,String videoName) {
//     final lines = file.readAsLinesSync();
//     var updatedLines = List<String>();

//     for (final String line in lines) {
//       var updatedLine = line;
//       if (line.contains('.ts') || line.contains('.m3u8')) {
//         updatedLine = '$videoName%2F$line?alt=media';
//       }
//       updatedLines.add(updatedLine);
//     }
//     final updatedContents =
//         updatedLines.reduce((value, element) => value + '\n' + element);

//     file.writeAsStringSync(updatedContents);
//   }

//   static bool checkAudio(Map info){
//     if(info['streams'].length <2){
//      return false;
//     }

//   return true;
//   }
//     Future<String> uploadFile(filePath, folderName,String postId) async {
//     final file = new File(filePath);
//     final basename = p.basename(filePath);
//     String videoUrl =
//         await FileStorage.upload('posts/$postId/$folderName', basename, file);
//     return videoUrl;
//   }

//   Future<String> _uploadHLSFiles(dirPath, videoName,String postId) async {
//     final videosDir = Directory(dirPath);

//     var playlistUrl = '';

//     final files = videosDir.listSync();
//     for (FileSystemEntity file in files) {
//       final fileName = p.basename(file.path);
//       final exploded = fileName.split('.');
//       final fileExtension = exploded[exploded.length - 1];
//       if (fileExtension == 'm3u8') updatePlaylistUrls(file, videoName);
//       final downloadUrl = await uploadFile(file.path, videoName,postId);

//       if (fileName == 'master.m3u8') {
//         playlistUrl = downloadUrl;
//       }
//     }
//     return playlistUrl;
//   }

//   Future<Map<String, String>> processVideo(File file,String postId) async {

//     final FlutterFFmpeg _encoder = FlutterFFmpeg();

//     final info = await getMediaInformation(file.path);
//     final aspectRatio = getAspectRatio(info);
//     double videoHeight;
//     double videoWidth;
//     if (aspectRatio >= 1) {
//       videoHeight = 540;
//       videoWidth = 540 * aspectRatio;
//     } else {
//       videoWidth = 540;
//       videoHeight = 540 / aspectRatio;
//     }

//     Directory appDocumentDir = await getExternalStorageDirectory();
//     final String outDir = '${appDocumentDir.path}/Videos/$postId';
//     final videosDir = new Directory(outDir);
//     videosDir.createSync(recursive: true);
//     String tempArguments = '';
//     videoWidth = 960;
//     videoHeight = 540;
//     if (VideoProcessing.checkAudio(info)) {
//       tempArguments = '-y -i ${file.path} ' +
//           '-preset fast -g 48 -sc_threshold 0 ' +
//           '-map 0:0 -map 0:1 -map 0:0 -map 0:1 ' +
//           '-r:v:1 24 -s:v:1 ${videoWidth.toInt()}x${videoHeight.toInt()} -c:v:1 libx265 -b:v:1 900k ' +
//           '-r:v:0 24 -s:v:0 ${(videoWidth * (360 / 540)).toInt()}x${(videoHeight * (360 / 540)).toInt()} -c:v:0 libx265 -b:v:0 145k ' +
//           '-c:a copy ' +
//           '-var_stream_map "v:0,a:0 v:1,a:1" ' +
//           '-master_pl_name master.m3u8 ' +
//           '-f hls -hls_time 6 -hls_list_size 0 ' +
//           '-hls_segment_filename "$outDir/%v_fileSequence_%d.ts" ' +
//           '$outDir/%v_playlistVariant.m3u8';
//     } else {
//       tempArguments = '-y -i ${file.path} ' +
//           '-preset fast -g 48 -sc_threshold 0 ' +
//           '-map 0:0 -map 0:0 ' +
//           '-r:v:1 24 -s:v:1 ${videoWidth.toInt()}x${videoHeight.toInt()} -c:v:1 libx265 -b:v:1 900k ' +
//           '-r:v:0 24 -s:v:0 ${(videoWidth * (360 / 540)).toInt()}x${(videoHeight * (360 / 540)).toInt()} -c:v:0 libx265 -b:v:0 145k ' +
//           '-var_stream_map "v:0 v:1" ' +
//           '-master_pl_name master.m3u8 ' +
//           '-f hls -hls_time 6 -hls_list_size 0 ' +
//           '-hls_segment_filename "$outDir/%v_fileSequence_%d.ts" ' +
//           '$outDir/%v_playlistVariant.m3u8';
//     }
//     await _encoder
//         .execute(tempArguments)

//     String thumbFilePath = await getThumb(
//         file.path,
//         (videoWidth * (300 / 540)).toInt(),
//         (videoHeight * (300 / 540)).toInt());

//     final String thumbUrl = await uploadFile(thumbFilePath, 'thumbnail',postId);
//     final String videoUrl = await _uploadHLSFiles(outDir, 'video_$postId',postId);
//     return {'thumbUrl': thumbUrl, 'videoUrl': videoUrl};
//   }

// }
