import 'package:flutter/material.dart';

Container sendButton({Function sendFunction}) {
  return Container(margin: EdgeInsets.only(top: 0,bottom: 4,right: 2,left: 2),height: 45,
      decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.blue),
    child: IconButton(
      icon: Icon(Icons.send,color: Colors.white,),
      onPressed: sendFunction,
    ),
  );
}
