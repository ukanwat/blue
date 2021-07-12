import 'dart:async';
import 'dart:io';

import 'package:blue/packages/ez_qr.dart/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'qrcode_reader_controller.dart';

/// Relevant privileges must be obtained before use
class QrcodeReaderView extends StatefulWidget {
  final Future Function(String) onScan;
  final ReaderFrom readerFrom;
  final Widget headerWidget;
  final double scanBoxRatio;
  final Color boxLineColor;
  final Widget helpWidget;
  final Color cornerColor;
  final Widget scanWidget;
  final Size screenCamSize;
  final Size positionCam;
  final Size closePositionButton;
  final Widget bottomContent;
  QrcodeReaderView({
    Key key,
    this.onScan,
    this.readerFrom = ReaderFrom.camera,
    this.headerWidget,
    this.boxLineColor = Colors.cyanAccent,
    this.helpWidget,
    this.scanBoxRatio = 0.85,
    this.cornerColor,
    this.scanWidget,
    this.screenCamSize,
    this.positionCam,
    this.closePositionButton,
    this.bottomContent,
  }) : super(key: key);

  @override
  QrcodeReaderViewState createState() => QrcodeReaderViewState();
}

/// Follow-up operations after scanning the code
/// ```dart
/// GlobalKey<QrcodeReaderViewState> qrViewKey = GlobalKey();
/// qrViewKey.currentState.startScan();
/// ```
class QrcodeReaderViewState extends State<QrcodeReaderView> {
  QrReaderViewController _controller;
  bool openFlashlight;
  bool hasCameraPermission = false;
  bool hasGalleryPermission = false;
  @override
  void initState() {
    super.initState();
    openFlashlight = false;

    SchedulerBinding.instance?.addPostFrameCallback((_) async {
      await setPermissionOfCamera();
      await setPermissionOfGallery();
    });
  }

  Future<void> setPermissionOfCamera() async {
    final cameraPermission = await Permission.camera.isGranted;
    var isCameraOk = !cameraPermission ? await getPermissionOfCamera() : true;

    if (isCameraOk) {
      setState(() {
        hasCameraPermission = true;
      });
    } else {
      Navigator.of(context).pop('Sem permissões para acessar a câmera');
    }
  }

  Future<void> setPermissionOfGallery() async {
    if (widget.readerFrom == ReaderFrom.gallery) {
      final galleryPermission = await Permission.storage.isGranted;
      var isGalleryOK =
          !galleryPermission ? await getPermissionOfGallery() : true;

      if (isGalleryOK) {
        setState(() {
          hasGalleryPermission = true;
        });
      } else {
        Navigator.of(context).pop('Sem permissões para acessar a galeria');
      }
    }
  }

  Future<bool> getPermissionOfCamera() async {
    var status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> getPermissionOfGallery() async {
    var status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  void _onCreateController(QrReaderViewController controller) async {
    _controller = controller;
    _controller.startCamera(_onQrBack);
  }

  bool isScan = false;
  Future _onQrBack(data, _) async {
    if (isScan == true) return;
    isScan = true;
    stopScan();
    await widget.onScan(data);
  }

  void startScan() {
    isScan = false;
    _controller.startCamera(_onQrBack);
  }

  void cameraFocus() async {
    await _controller.cameraFocus();
  }

  void stopScan() {
    _controller.stopCamera();
  }

  Future<bool> setFlashlight() async {
    openFlashlight = await _controller.setFlashlight();
    setState(() {});
    return openFlashlight;
  }

  Future _scanImage() async {
    final picker = ImagePicker();
    var status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      var image = await picker.getImage(source: ImageSource.gallery);
      if (image == null) {
        Navigator.of(context).pop();
        return;
      }
      final file = File(image.path);
      final rest = await FlutterQrReader.imgScan(file);
      await widget.onScan(rest);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: !hasCameraPermission ? Colors.black : null,
      child: !hasCameraPermission
          ? Container(
              color: Colors.black,
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                if (widget.readerFrom == ReaderFrom.gallery) {
                  _scanImage();
                  return Container(color: Colors.transparent);
                }
                final qrScanSize =
                    constraints.maxWidth * (widget.scanBoxRatio ?? 1);
                // final mediaQuery = MediaQuery.of(context);
                if (constraints.maxHeight < qrScanSize * 1.5) {
                  debugPrint(
                    'It is recommended that the height to scan area height ratio be greater than 1.5',
                  );
                }
                return Stack(
                  children: <Widget>[
                    //ImagePreview
                    Positioned(
                      left: widget.positionCam?.width ??
                          (constraints.maxWidth - qrScanSize) / 2,
                      top: widget.positionCam?.height ??
                          (constraints.maxHeight - qrScanSize) / 2,
                      child: SizedBox(
                        width: widget.screenCamSize?.width ??
                            constraints.maxWidth * 0.84,
                        height: widget.screenCamSize?.height ??
                            constraints.maxWidth * 0.84,
                        child: QrReaderView(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          callback: _onCreateController,
                        ),
                      ),
                    ),
                    widget.headerWidget ?? SizedBox(),
                    //Mask Position
                    //
                    widget.scanWidget ??
                        Positioned(
                          left: (constraints.maxWidth - qrScanSize) / 2,
                          top: (constraints.maxHeight - qrScanSize) / 2,
                          child: CustomPaint(
                            painter: QrScanBoxPainter(
                              boxLineColor: widget.boxLineColor ?? Colors.red,
                              cornerColor: widget.cornerColor ?? Colors.green,
                            ),
                            child: SizedBox(
                              width: qrScanSize,
                              height: qrScanSize,
                            ),
                          ),
                        ),

                    Positioned(
                      top: (constraints.maxHeight - qrScanSize) * (1 / 2) +
                          qrScanSize +
                          24,
                      width: constraints.maxWidth,
                      child: Align(
                        alignment: Alignment.center,
                        child: widget.bottomContent,
                      ),
                    ),

                    Positioned(
                      top: widget.closePositionButton?.height ??
                          MediaQuery.of(context).size.width * .1,
                      left: widget.closePositionButton?.width ??
                          MediaQuery.of(context).size.width * .085,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          color: const Color(0xff969696),
                        ),
                      ),
                    ),

                    Positioned(
                      top: widget.closePositionButton?.height ??
                          MediaQuery.of(context).size.width * .1,
                      right: widget.closePositionButton?.width ??
                          MediaQuery.of(context).size.width * .085,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: setFlashlight,
                        child: Icon(
                          openFlashlight
                              ? Icons.wb_sunny_outlined
                              : Icons.wb_sunny,
                          color: const Color(0xff969696),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class QrScanBoxPainter extends CustomPainter {
  final double animationValue;
  final bool isForward;
  final Color boxLineColor;
  final Color cornerColor;

  QrScanBoxPainter({
    this.cornerColor,
    this.animationValue = 0,
    this.isForward = false,
    this.boxLineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderRadius = BorderRadius.all(Radius.circular(12)).toRRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawRRect(
      borderRadius,
      Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    final borderPaint = Paint()
      ..color = cornerColor ?? Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    final path = Path();
    // leftTop
    path.moveTo(0, 50);
    path.lineTo(0, 12);
    path.quadraticBezierTo(0, 0, 12, 0);
    path.lineTo(50, 0);
    // rightTop
    path.moveTo(size.width - 50, 0);
    path.lineTo(size.width - 12, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 12);
    path.lineTo(size.width, 50);
    // rightBottom
    path.moveTo(size.width, size.height - 50);
    path.lineTo(size.width, size.height - 12);
    path.quadraticBezierTo(
        size.width, size.height, size.width - 12, size.height);
    path.lineTo(size.width - 50, size.height);
    // leftBottom
    path.moveTo(50, size.height);
    path.lineTo(12, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 12);
    path.lineTo(0, size.height - 50);

    canvas.drawPath(path, borderPaint);

    canvas.clipRRect(
        BorderRadius.all(Radius.circular(12)).toRRect(Offset.zero & size));

    // 绘制横向网格
    // final linePaint = Paint();
    // final lineSize = size.height * 0.45;
    // final leftPress = (size.height + lineSize) * animationValue - lineSize;
    // linePaint.style = PaintingStyle.stroke;
    // linePaint.shader = LinearGradient(
    //   colors: [Colors.transparent, boxLineColor],
    //   begin: isForward ? Alignment.topCenter : Alignment(0.0, 2.0),
    //   end: isForward ? Alignment(0.0, 0.5) : Alignment.topCenter,
    // ).createShader(Rect.fromLTWH(0, leftPress, size.width, lineSize));
    // for (int i = 0; i < size.height / 5; i++) {
    //   canvas.drawLine(
    //     Offset(
    //       i * 5.0,
    //       leftPress,
    //     ),
    //     Offset(i * 5.0, leftPress + lineSize),
    //     linePaint,
    //   );
    // }
    // for (int i = 0; i < lineSize / 5; i++) {
    //   canvas.drawLine(
    //     Offset(0, leftPress + i * 5.0),
    //     Offset(
    //       size.width,
    //       leftPress + i * 5.0,
    //     ),
    //     linePaint,
    //   );
    // }
  }

  @override
  bool shouldRepaint(QrScanBoxPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;

  @override
  bool shouldRebuildSemantics(QrScanBoxPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
