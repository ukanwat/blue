import 'package:blue/services/preferences_update.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flick_video_player/flick_video_player.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../main.dart';

class VideoDisplay extends StatefulWidget {
  final FlickManager flickManager;
  final bool autoplay;
  final Widget thumbnail;
  VideoDisplay(this.flickManager, this.autoplay, {this.thumbnail});

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> with RouteAware {
  /// Called when the current route has been popped off.
  @override
  void didPop() {
    widget.flickManager.flickControlManager.autoPause();
    super.didPop();
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {
    widget.flickManager.flickControlManager.autoPause();
    super.didPopNext();
  }

  /// Called when the current route has been pushed.
  @override
  void didPush() {
    widget.flickManager.flickControlManager.autoPause();
    super.didPush();
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {
    widget.flickManager.flickControlManager.autoPause();
    super.didPushNext();
  }

  @override
  void dispose() {
    widget.flickManager.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(widget.flickManager),
      onVisibilityChanged: (visibility) {
        if (widget.autoplay) {
          if (visibility.visibleFraction == 0 && this.mounted) {
            widget.flickManager.flickControlManager.autoPause();
          } else if (visibility.visibleFraction == 1) {
            bool autoplay = PreferencesUpdate().getBool('autoplay_videos');
            if (autoplay == true) {
              widget.flickManager.flickControlManager.autoResume();
            } else {}
          }
        }
      },
      child: Container(
        child: FlickVideoPlayer(
          flickManager: widget.flickManager,
          wakelockEnabledFullscreen: true,
          wakelockEnabled: true,
          flickVideoWithControls: FlickVideoWithControls(
            playerLoadingFallback: widget.thumbnail ??
                Positioned.fill(
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(
                          color: Colors.black,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            strokeWidth: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            controls: PortraitVideoControls(
              pauseOnTap: true,
            ),
          ),
          flickVideoWithControlsFullscreen: FlickVideoWithControls(
            videoFit: BoxFit.contain,
            playerLoadingFallback: Center(child: Icon(Icons.warning)),
            controls: LandscapeVideoControls(),
            iconThemeData: IconThemeData(
              size: 40,
              color: Colors.white,
            ),
            textStyle: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class LandscapeVideoControls extends StatelessWidget {
  const LandscapeVideoControls(
      {Key key, this.iconSize = 20, this.fontSize = 12})
      : super(key: key);
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FlickShowControlsAction(
          child: FlickSeekVideoAction(
            child: Center(
              child: FlickVideoBuffer(
                child: FlickAutoHideChild(
                  showIfVideoNotInitialized: false,
                  child: LandscapePlayToggle(),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.4),
                      borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FlickAutoHideChild(
                          child: FlickFullScreenToggle(
                        size: 28,
                        padding: EdgeInsets.all(4),
                      )),
                      SizedBox(
                        width: 10,
                      ),
                      FlickCurrentPosition(
                        fontSize: fontSize,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          child: FlickVideoProgressBar(
                            flickProgressBarSettings: FlickProgressBarSettings(
                              height: 10,
                              handleRadius: 10,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 8,
                              ),
                              backgroundColor: Colors.white24,
                              bufferedColor: Colors.white38,
                              getPlayedPaint: (
                                  {double handleRadius,
                                  double height,
                                  double playedPart,
                                  double,
                                  width}) {
                                return Paint()
                                  ..shader = LinearGradient(colors: [
                                    Colors.blue.withOpacity(0.6),
                                    Colors.blue
                                  ], stops: [
                                    0.0,
                                    0.5
                                  ]).createShader(
                                    Rect.fromPoints(
                                      Offset(0, 0),
                                      Offset(width, 0),
                                    ),
                                  );
                              },
                              getHandlePaint: (
                                  {double handleRadius,
                                  double height,
                                  double playedPart,
                                  double,
                                  width}) {
                                return Paint()
                                  ..shader = RadialGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white,
                                    ],
                                    stops: [0.0, 0.5],
                                    radius: 0.4,
                                  ).createShader(
                                    Rect.fromCircle(
                                      center: Offset(playedPart, height / 2),
                                      radius: handleRadius,
                                    ),
                                  );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      FlickTotalDuration(
                        fontSize: fontSize,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      FlickSoundToggle(
                        toggleMute: () {},
                        padding: EdgeInsets.all(5),
                        size: 26,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PortraitVideoControls extends StatelessWidget {
  const PortraitVideoControls({
    Key key,
    this.pauseOnTap,
  }) : super(key: key);
  final bool pauseOnTap;

  @override
  Widget build(BuildContext context) {
    FlickVideoManager flickVideoManager =
        Provider.of<FlickVideoManager>(context);
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    return Container(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          Animation<Offset> animationOffset;
          Animation<Offset> inAnimation =
              Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                  .animate(animation);
          Animation<Offset> outAnimation =
              Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0))
                  .animate(animation);

          animationOffset =
              child.key == ObjectKey(flickVideoManager.videoPlayerController)
                  ? inAnimation
                  : outAnimation;

          return SlideTransition(
            position: animationOffset,
            child: child,
          );
        },
        child: Container(
          key: ObjectKey(
            flickVideoManager.videoPlayerController,
          ),
          child: FlickVideoWithControls(
            willVideoPlayerControllerChange: false,
            playerLoadingFallback: Positioned.fill(
              child: Container(),
            ),
            controls: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: IconTheme(
                data: IconThemeData(color: Colors.white, size: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: pauseOnTap
                          ? FlickTogglePlayAction(
                              child: FlickSeekVideoAction(
                                child: Center(child: FlickVideoBuffer()),
                              ),
                            )
                          : FlickToggleSoundAction(
                              child: FlickSeekVideoAction(
                                child: Center(child: FlickVideoBuffer()),
                              ),
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlickAutoHideChild(
                          autoHide: true,
                          showIfVideoNotInitialized: false,
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8)),
                                  color: Colors.black45),
                              child: FlickFullScreenToggle(
                                size: 24,
                                padding: EdgeInsets.all(1.5),
                              )),
                        ),
                        SizedBox(
                          width: 0.8,
                        ),
                        FlickAutoHideChild(
                          showIfVideoNotInitialized: false,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8)),
                              ),
                              child: FlickLeftDuration(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        if (flickVideoManager.isVideoEnded)
                          FlickAutoHideChild(
                              autoHide: true,
                              showIfVideoNotInitialized: false,
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.black45),
                                  child: GestureDetector(
                                      onTap: () {
                                        controlManager.replay();
                                      },
                                      child: Icon(
                                        Icons.replay,
                                        color: Colors.white,
                                        size: 28,
                                      )))),
                        if (!flickVideoManager.isVideoEnded)
                          FlickAutoHideChild(
                            autoHide: true,
                            showIfVideoNotInitialized: false,
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black45),
                                child: FlickSoundToggle(
                                  size: 24,
                                  padding: EdgeInsets.all(1.5),
                                )),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LandscapePlayToggle extends StatelessWidget {
  const LandscapePlayToggle({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    double size = 50;
    Color color = Colors.white;

    Widget playWidget = Icon(
      Icons.play_arrow,
      size: size,
      color: color,
    );
    Widget pauseWidget = Icon(
      Icons.pause,
      size: size,
      color: color,
    );
    Widget replayWidget = Icon(
      Icons.replay,
      size: size,
      color: color,
    );

    Widget child = videoManager.isVideoEnded
        ? replayWidget
        : videoManager.isPlaying
            ? pauseWidget
            : playWidget;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        splashColor: Color.fromRGBO(108, 165, 242, 0.5),
        key: key,
        onTap: () {
          videoManager.isVideoEnded
              ? controlManager.replay()
              : controlManager.togglePlay();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: EdgeInsets.all(10),
          child: child,
        ),
      ),
    );
  }
}
