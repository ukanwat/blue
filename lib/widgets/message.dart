// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

import 'package:dio/dio.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/constants/app_colors.dart';

class Message extends StatelessWidget {
  final int id;
  final int idTo;
  final int idFrom;
  final DateTime timestamp;
  final String message;
  final String type;
  final bool deletedBySender;
  Message(
      {this.id,
      this.idTo,
      this.idFrom,
      this.timestamp,
      this.message,
      this.type,
      this.deletedBySender});

  factory Message.fromDocument(Map doc) {
    return Message(
      id: doc['msg_id'],
      idTo: doc['recipient_id'],
      idFrom: doc['sender_id'],
      timestamp: DateTime.parse(doc['created_at']),
      message: doc['data'],
      type: doc['type'],
      deletedBySender: doc['deletedBySender'],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool myText = Boxes.currentUserBox.get('user_id') == idFrom;
    return (deletedBySender == true && myText) ||
            (deletedBySender == false && !myText)
        ? Container()
        : Container(
            padding: EdgeInsets.all(8),
            child: type == 'image' || type == 'gif'
                ? Row(
                    children: <Widget>[
                      if (myText)
                        Container(
                          width: MediaQuery.of(context).size.width * .2,
                        ),
                      Expanded(
                        child: InkWell(
                          onLongPress: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0.0,
                                    backgroundColor: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        Navigator.pop(context);
                                        var response = await Dio().get(message,
                                            options: Options(
                                                responseType:
                                                    ResponseType.bytes));

                                        await ImageGallerySaver.saveImage(
                                            Uint8List.fromList(response.data),
                                            quality: 100,
                                            name: "Stark");
                                        snackbar('image saved', context);
                                      },
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 20),
                                          decoration: new BoxDecoration(
                                            color:
                                                Theme.of(context).canvasColor,
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 10.0,
                                                offset: const Offset(0.0, 10.0),
                                              ),
                                            ],
                                          ),
                                          child: Container(
                                            height: 20,
                                            child: Center(
                                                child: Text(
                                              'Save to storage',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                          )),
                                    )));
                          },
                          child: Container(
                            padding: EdgeInsets.all(0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context).cardColor,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.transparent),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: FullScreenWidget(
                                  child: Center(
                                    child: Hero(
                                      tag: '$idFrom$timestamp',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: CachedNetworkImage(
                                          imageUrl: message,
                                          placeholder: (context, url) =>
                                              Container(
                                                  height: 150,
                                                  child: Center(
                                                      child:
                                                          circularProgress())),
                                          errorWidget: (context, url, error) =>
                                              Padding(
                                            padding: const EdgeInsets.all(50.0),
                                            child: new Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ),
                      if (!myText)
                        Container(
                          width: MediaQuery.of(context).size.width * .2,
                        ),
                    ],
                  )
                : Row(
                    children: <Widget>[
                      if (myText) Expanded(child: Container()),
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * .76),
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 9),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: myText
                                ? AppColors.blue
                                : Theme.of(context).backgroundColor,
                            border: Border.all(
                                color: myText ? AppColors.blue : Colors.grey,
                                width: 0.6)),
                        child: Text(
                          message,
                          style: TextStyle(
                              fontSize: 16,
                              color: myText
                                  ? Colors.white
                                  : Theme.of(context).iconTheme.color),
                        ),
                      ),
                      if (!myText) Expanded(child: Container())
                    ],
                  ),
          );
  }

  Widget loadingBuilder() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(
          Color.fromRGBO(3, 23, 84, 1),
        ),
      ),
    );
  }
}
