import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:flutter/material.dart';
import 'package:blue/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:full_screen_image/full_screen_image.dart';

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

  factory Message.fromDocument(Map doc) {
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
                                  await ImageDownloader.downloadImage( // might not work after changing rules
                                    message,
                                    destination: AndroidDestinationType.custom(  
                                        directory: '/Pictures/Scrible'),
                                    outputMimeType: type == 'image'
                                        ? "image/jpg"
                                        : "image/gif",
                                  );
                                },
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    decoration: new BoxDecoration(
                                      color: Theme.of(context).canvasColor,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
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
                                    placeholder: (context, url) => Padding(
                                      padding: const EdgeInsets.all(50.0),
                                      child: new CircularProgressIndicator(),
                                    ),
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
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 9),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: myText
                          ? Colors.blue
                          : Theme.of(context).backgroundColor,
                      border: Border.all(
                          color: myText ? Colors.blue : Colors.grey,
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
