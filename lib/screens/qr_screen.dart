import 'dart:io';

import 'package:blue/packages/ez_qr.dart/scan_view.dart';
import 'package:blue/packages/ez_qr.dart/utils.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/dynamic_links.dart';
import 'package:blue/services/functions.dart';
import 'package:blue/services/go_to.dart';
import 'package:blue/widgets/progress.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:majascan/majascan.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share/share.dart';

class QRScreen extends StatefulWidget {
  static const routeName = 'qr';
  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  bool scanMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: FlutterGradients.aquaGuidance(tileMode: TileMode.clamp)),
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).padding.top,
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    FlutterIcons.remove_faw,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                Expanded(child: Container()),
                IconButton(
                  onPressed: () async {
                    String _link = await DynamicLinksService.createDynamicLink(
                        "user?id=${Boxes.currentUserBox.get('user_id')}");
                    Share.share(_link, subject: 'Sharing Profile');
                  },
                  icon: Icon(
                    FlutterIcons.share_alt_faw5s,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                setState(() {
                  scanMode = !scanMode;
                });
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 170,
                  height: 65,
                  child: Column(
                    children: [
                      Text(
                        scanMode ? 'Show Code' : 'Scan Code',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            fontFamily: 'Stark Sans'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          FluentIcons.arrow_sync_12_filled,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 1, color: Colors.white)),
                ),
              ),
            ),
            Expanded(
              child: Center(
                  child: Container(
                child: scanMode
                    ? Center(
                        child: Container(
                          width: 200,
                          height: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  String results = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScanView(
                                        cornerColor: Colors.blue,
                                        readerFrom: ReaderFrom.camera,
                                        bottomContent: Text(
                                          'Scan QR Code',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Stark Sans',
                                              color:
                                                  Theme.of(context).accentColor,
                                              fontSize: 20),
                                        ),
                                        scanWidget: Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  // color: Colors.greenAccent
                                                  //     .withOpacity(0.2),
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );

                                  await Functions()
                                      .handleFollowUser(int.parse(results));
                                  GoTo().profileScreen(
                                      context, int.parse(results));
                                  print(results);
                                },
                                child: Container(
                                  height: 90,
                                  width: 90,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Center(
                                            child: Icon(
                                                FluentIcons.camera_16_filled)),
                                      ),
                                      Text(
                                        'Scan From Camera',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(child: VerticalDivider()),
                              GestureDetector(
                                onTap: () async {
                                  String results = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScanView(
                                        cornerColor: Colors.blue,
                                        readerFrom: ReaderFrom.gallery,
                                      ),
                                    ),
                                  );
                                  try {
                                    int numb = int.parse(results);
                                  } catch (e) {
                                    snackbar('QR code not recognised', context,
                                        color: Colors.red);
                                    return;
                                  }

                                  await Functions()
                                      .handleFollowUser(int.parse(results));
                                  GoTo().profileScreen(
                                      context, int.parse(results));
                                },
                                child: Container(
                                  height: 90,
                                  width: 90,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(FluentIcons
                                          .content_view_gallery_20_filled),
                                      Text(
                                        'Scan From  Gallery',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : PrettyQr(
                        image: AssetImage('assets/logo.png'),
                        typeNumber: 3,
                        size: 200,
                        data: Boxes.currentUserBox.get('user_id').toString(),
                        errorCorrectLevel: QrErrorCorrectLevel.M,
                        roundEdges: true,
                      ),
                padding: EdgeInsets.all(15),
                height:
                    scanMode ? 100 : MediaQuery.of(context).size.width * 0.65,
                width:
                    scanMode ? 240 : MediaQuery.of(context).size.width * 0.65,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 30,
                left: 20,
                right: 20,
              ),
              child: Text(
                scanMode
                    ? "Scan your friend's code to follow them"
                    : 'Your Friends can scan this QR code to follow you',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Stark Sans'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
