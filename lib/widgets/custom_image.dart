// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

Widget cachedNetworkImage(BuildContext context,String mediaUrl,{double aspectRatio}) {
  if(mediaUrl == null){
    return Container(color: Colors.grey[300],
      height:MediaQuery.of(context).size.width/aspectRatio ,
    );
  }
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: aspectRatio == null? null:(context, url) =>  Container(color: Colors.grey[300],
      height:MediaQuery.of(context).size.width/aspectRatio ,
      

    )
  );
}
