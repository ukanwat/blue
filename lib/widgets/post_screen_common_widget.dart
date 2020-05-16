import 'package:flutter/material.dart';

import '../models/user.dart';


class PostScreenCommonWidget extends StatelessWidget {
  final TextEditingController captionController;
  final User currentUser;
  PostScreenCommonWidget({this.captionController, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
         Container(padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            width: double.infinity,
            child: TextField(style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),
              maxLines: 2,
              controller: captionController,
              decoration: InputDecoration(
                hintText: "An Interesting Title...",
                border: InputBorder.none,
              ),
            ),
          ),
        
      ],
    );
  }
}
