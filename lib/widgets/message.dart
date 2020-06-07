import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:blue/screens/home.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class Message extends StatelessWidget {
  final String idTo;
  final String idFrom;
  final Timestamp timestamp;
  final String message;
  final String type;
  Message({
    this.idTo,
    this.idFrom,
    this.timestamp,
    this.message,
    this.type,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      idTo: doc['idTo'],
      idFrom: doc['idFrom'],
      timestamp: doc['timestamp'],
      message: doc['message'],
      type: doc['type'],
    );
  }
  @override
  Widget build(BuildContext context) {
    bool myText = currentUser.id == idFrom;
    return Container(
      padding: EdgeInsets.all(8),
      child: type == 'image'
          ?  Row(
            children: <Widget>[
            if(myText)  Container(
                width: MediaQuery.of(context).size.width * .2,
              ),
              Expanded(
                              child: Container(padding: EdgeInsets.all(2),
                     decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: myText ? Colors.blue : Colors.grey[200],
                            
                          ),
                      child: ClipRRect(borderRadius: BorderRadius.circular(14),clipBehavior: Clip.antiAliasWithSaveLayer,
                                        child: Image(
                          image: CachedNetworkImageProvider(message)),
                      ),
                    
                ),
              ),
          if(!myText)    Container(
                width: MediaQuery.of(context).size.width * .2,
              ),
            ],
          )
          : Row(
              children: <Widget>[ if(myText)Expanded(child: Container()),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .6),
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: myText ? Colors.blue : Colors.grey[200],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                        fontSize: 16,
                        color: myText ? Colors.white : Colors.black),
                  ),
                ),
              if(!myText)Expanded(child: Container())
              ],
            ),
    );
  }
}
