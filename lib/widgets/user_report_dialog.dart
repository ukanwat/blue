import 'package:blue/main.dart';
import 'package:blue/services/functions.dart';
import 'package:flutter/material.dart';
class UserReportDialog extends StatefulWidget {
  final Map peer;
  UserReportDialog({
    this.peer
  });

  @override
  _UserReportDialogState createState() => _UserReportDialogState();
}

class _UserReportDialogState extends State<UserReportDialog> {
  Map peer ={};
  String   groupChatId ;
  @override
  void initState() {
peer = widget.peer;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return   Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0.0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      decoration: new BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // To make the card compact
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Text(
                              'Report',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Tell us your reason for reporting ${peer['peerUsername']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Divider(
                            height: 5,
                            thickness: 1,
                         color: Theme.of(context).cardColor
                          ),
                          InkWell(
                            onTap: () async {
                              Functions().updateReportFirebase(peer,'spam');

                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 40,
                              child: Center(child: Text("It's Spam",style: TextStyle(fontSize: 18),)),
                            ),
                          ),
                          Divider(
                            height: 5,
                            thickness:1,
                           color: Theme.of(context).cardColor
                          ),
                          InkWell(
                            onTap: () {
                              Functions().updateReportFirebase(peer,'inappropriate');
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 40,
                              child: Center(child: Text("It's Inappropriate",style: TextStyle(fontSize: 18),)),
                            ),
                          ),
                          Divider(
                            height: 5,
                            thickness: 1,
                            color: Theme.of(context).cardColor
                          ),
                          InkWell(
                            onTap: () {
                              Functions().updateReportFirebase(peer,'abusive');
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 40,
                              child: Center(child: Text("It's abusive",style: TextStyle(fontSize: 18),)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
  }
}