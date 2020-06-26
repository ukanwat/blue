import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

Container sendButton({Function sendFunction}) {
  return Container(margin: EdgeInsets.only(top: 2,bottom: 6,right: 4,left: 4),height: 41,
      decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.blue),
    child: IconButton(
      icon: Icon(FlutterIcons.send_fea,color: Colors.white,),
      onPressed: sendFunction,
    ),
  );
}
