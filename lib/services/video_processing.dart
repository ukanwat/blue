import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

class VideoProcessing {
  static final FlutterFFmpeg _encoder = FlutterFFmpeg();
  static final FlutterFFprobe _probe = FlutterFFprobe();
  // static final FlutterFFmpegConfig _config = FlutterFFmpegConfig();

  static Future<String> getThumb(videoPath, width, height) async {
    assert(File(videoPath).existsSync());

    final String outPath = '$videoPath.jpg';
    final arguments =
        '-y -i $videoPath -vframes 1 -an -s ${width}x$height -ss 1 $outPath';

    final int rc = await _encoder.execute(arguments);
    assert(rc == 0);
    assert(File(outPath).existsSync());

    return outPath;
  }

  static Future<Map<dynamic, dynamic>> getMediaInformation(String path) async {
    return await _probe.getMediaInformation(path);
  }

  static double getAspectRatio(Map<dynamic, dynamic> info) {
    final int width = info['streams'][0]['width'];
    final int height = info['streams'][0]['height'];
    final double aspect = height / width;
    return aspect;
  }

  static int getDuration(Map<dynamic, dynamic> info) {
    return info['duration'];
  }

  

  void updatePlaylistUrls(File file, String videoName) {
    final lines = file.readAsLinesSync();
    var updatedLines = List<String>();

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = '$videoName%2F$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final updatedContents =
        updatedLines.reduce((value, element) => value + '\n' + element);

    file.writeAsStringSync(updatedContents);
  }

  static bool checkAudio(Map info){
    if(info['streams'].length <2){
     return false;
    }

  return true;
  }
  
}
