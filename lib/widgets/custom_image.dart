// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

Widget cachedNetworkImage(BuildContext context, String mediaUrl,
    {double aspectRatio, String blurHash}) {
  if (mediaUrl == null) {
    return Container(
      color: Colors.grey[300],
      height: MediaQuery.of(context).size.width / aspectRatio,
    );
  }

  return CachedNetworkImage(
      imageUrl: mediaUrl,
      fit: BoxFit.cover,
      fadeOutDuration: Duration(milliseconds: 400),
      fadeInDuration: Duration(milliseconds: 400),
      fadeInCurve: Curves.easeOut,
      fadeOutCurve: Curves.easeIn,
      placeholder: aspectRatio == null
          ? null
          : (context, url) => Container(
                color: Colors.grey[300],
                height: MediaQuery.of(context).size.width / aspectRatio,
                child:
                    blurHash == null ? Container() : BlurHash(hash: blurHash),
              ));
}

class PostImage extends StatelessWidget {
  final String url;
  final double aR;
  final String blurHash;

  const PostImage(this.url, this.aR, this.blurHash);

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url,
      cache: true,
      fit: BoxFit.fill,
      mode: ExtendedImageMode.gesture,
      initGestureConfigHandler: (state) {
        return GestureConfig(
          minScale: 0.9,
          animationMinScale: 0.7,
          maxScale: 3.0,
          animationMaxScale: 3.5,
          speed: 1.0,
          inertialSpeed: 100.0,
          initialScale: 1.0,
          inPageView: false,
          initialAlignment: InitialAlignment.center,
        );
      },
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / aR,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return BlurHash(hash: blurHash);
            break;
          case LoadState.completed:
            return null;
            break;
          case LoadState.failed:
            return GestureDetector(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width / aR,
                  ),
                  // Image.asset(
                  //   "assets/failed.jpg",
                  //   fit: BoxFit.fill,
                  // ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        "loading failed, click to reload",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              onTap: () {
                state.reLoadImage();
              },
            );
            break;
        }
        return Container();
      },
    );
  }
}
