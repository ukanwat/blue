// Flutter imports:
import 'package:blue/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flick_video_player/flick_video_player.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer/video_viewer.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Project imports:
import 'package:blue/services/preferences_update.dart';
import '../main.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';

class Video extends StatefulWidget {
  final String url;
  final String thumbnail;
  final double aspectRatio;
  Video(this.url, this.aspectRatio, this.thumbnail);

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends VisibilityAwareState<Video> with RouteAware {
  @override
  void didPop() {
    videoController.pause();
    super.didPop();
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {
    videoController.pause();
    super.didPopNext();
  }

  /// Called when the current route has been pushed.
  @override
  void didPush() {
    videoController.pause();
    super.didPush();
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {
    videoController.pause();
    super.didPushNext();
  }

  @override
  void dispose() {
    videoController.pause();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));

    super.didChangeDependencies();
  }

  @override
  void initState() {
    autoplay = PreferencesUpdate().getBool('autoplay_videos') ?? true;
    super.initState();
  }

  final VideoViewerController videoController = VideoViewerController();
  bool autoplay;
  bool start = true;

  @override
  void onVisibilityChanged(WidgetVisibility visibility) {
    if (visibility == WidgetVisibility.GONE ||
        visibility == WidgetVisibility.INVISIBLE) {
      videoController.pause();
    } else if (visibility == WidgetVisibility.VISIBLE) {
      if (autoplay == true) {
        videoController.play();
      } else {}
    }
    if (start) {
      if (visibility == WidgetVisibility.VISIBLE) {
        videoController.pause();
      }
      start = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: ObjectKey(widget.url),
        onVisibilityChanged: (visibility) {
          if (visibility.visibleFraction == 0 && this.mounted) {
            videoController.pause();
          } else if (visibility.visibleFraction == 1) {
            if (autoplay == true) {
              videoController.play();
            } else {}
          }
          if (start) {
            if (visibility.visibleFraction < 1 && this.mounted) {
              videoController.pause();
            }
            start = false;
          }
        },
        child: Stack(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width / widget.aspectRatio,
                child: Container(
                  child: VideoViewer(
                    enableVerticalSwapingGesture: false,
                    enableFullscreenScale: false,
                    autoPlay: false,
                    controller: videoController,
                    defaultAspectRatio: widget.aspectRatio,
                    style: VideoViewerStyle(
                      volumeBarStyle: VolumeBarStyle(
                          bar: BarStyle.volume(
                              background: Colors.transparent,
                              color: Colors.transparent)),
                      loading: circularProgress(),
                      progressBarStyle: ProgressBarStyle(
                          bar: BarStyle.progress(
                        color: Colors.white,
                      )),
                      settingsStyle: SettingsMenuStyle(
                          settings: Icon(FlutterIcons.gear_oct,
                              color: Colors.white, size: 20)),
                      playAndPauseStyle: PlayAndPauseWidgetStyle(
                          play: Icon(FluentIcons.play_12_filled,
                              color: Colors.white),
                          pause: Icon(FluentIcons.pause_12_filled,
                              color: Colors.white),
                          replay: Icon(
                              FluentIcons.arrow_counterclockwise_12_filled,
                              color: Colors.white),
                          background: Colors.black26,
                          circleRadius: 50),
                      thumbnail: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width /
                            widget.aspectRatio,
                        child: CachedNetworkImage(
                          imageUrl: widget.thumbnail,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    volumeManager: VideoViewerVolumeManager.device,
                    source: {
                      "SubRip Text": VideoSource(
                        video: VideoPlayerController.network(widget.url),
                      )
                    },
                  ),
                )),
          ],
        ));
  }
}
