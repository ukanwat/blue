// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

Widget cachedNetworkImage(BuildContext context,String mediaUrl,{double aspectRatio,String blurHash}) {
  if(mediaUrl == null){
    return Container(color: Colors.grey[300],
      height:MediaQuery.of(context).size.width/aspectRatio ,
    );
  }
  
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,fadeOutDuration: Duration(milliseconds: 400),fadeInDuration: Duration(milliseconds: 400),fadeInCurve: Curves.easeOut,fadeOutCurve: Curves.easeIn,
    placeholder: aspectRatio == null? null:(context, url) =>  Container(color: Colors.grey[300],
      height:MediaQuery.of(context).size.width/aspectRatio ,
      
        child: blurHash==null?Container():BlurHash(hash: blurHash),
    )
  );
}
