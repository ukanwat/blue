import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './qrcode_reader_view.dart';
import 'qrcode_reader_view.dart';
import 'utils.dart';

class ScanView extends StatefulWidget {
  final Color cornerColor;
  final Widget scanWidget;
  final Size screenCamSize;
  final Size positionCam;
  final Function(String) afterScan;
  final Widget bottomContent;
  final ReaderFrom readerFrom;

  ScanView({
    Key key,
    this.cornerColor,
    this.scanWidget,
    this.screenCamSize,
    this.positionCam,
    this.afterScan,
    this.bottomContent,
    this.readerFrom,
  }) : super(key: key);

  @override
  _ScanViewState createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  final GlobalKey<QrcodeReaderViewState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QrcodeReaderView(
        readerFrom: widget.readerFrom,
        key: _key,
        onScan: onScan,
        // headerWidget: AppBar(
        //   backgroundColor: Colors.red,
        //   elevation: 0.0,
        // ),
        screenCamSize: widget.screenCamSize,
        positionCam: widget.positionCam,
        cornerColor: widget.cornerColor ?? Colors.white,
        scanWidget: widget.scanWidget ??
            Center(
              child: Container(
                // padding: EdgeInsets.all(),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 5.0,
                    color: Colors.green,
                    style: BorderStyle.solid,
                  ),
                ),
                width: MediaQuery.of(context).size.width * (0.9),
                height: MediaQuery.of(context).size.width * (0.9),
              ),
            ),
        bottomContent: widget.bottomContent ??
            Container(
              padding: EdgeInsets.symmetric(horizontal: 64),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Centralize o QR Code na área demarcada',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Future onScan(String data) async {
    if (widget.afterScan != null) {
      widget.afterScan(data);
    } else {
      Navigator.of(context).pop(data);
    }
  }
}
