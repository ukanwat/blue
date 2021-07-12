import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlutterQrReader {
  static const MethodChannel _channel =
      MethodChannel('br.com.flutterando.ez_qr');

  static Future<String> imgScan(File file) async {
    if (file.existsSync() == false) {
      return '';
    }
    try {
      final rest = await _channel.invokeMethod('imgQrCode', {
        'file': file.path,
      });
      return rest;
    } catch (e) {
      debugPrint('imgScan: $e');
      return '';
    }
  }
}

class QrReaderView extends StatefulWidget {
  final Function(QrReaderViewController) callback;

  final int autoFocusIntervalInMs;
  final bool torchEnabled;
  final double width;
  final double height;

  QrReaderView({
    Key key,
    this.width,
    this.height,
    this.callback,
    this.autoFocusIntervalInMs = 500,
    this.torchEnabled = false,
  }) : super(key: key);

  @override
  _QrReaderViewState createState() => _QrReaderViewState();
}

class _QrReaderViewState extends State<QrReaderView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'br.com.flutterando.ez_qr.reader_view',
        creationParams: {
          'width': (widget.width * window.devicePixelRatio).floor(),
          'height': (widget.height * window.devicePixelRatio).floor(),
          'extra_focus_interval': widget.autoFocusIntervalInMs,
          'extra_torch_enabled': widget.torchEnabled,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'br.com.flutterando.ez_qr.reader_view',
        creationParams: {
          'width': widget.width,
          'height': widget.height,
          'extra_focus_interval': widget.autoFocusIntervalInMs,
          'extra_torch_enabled': widget.torchEnabled,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
      );
    } else {
      return Text('The platform does not currently support');
    }
  }

  void _onPlatformViewCreated(int id) {
    widget.callback(
      QrReaderViewController(id),
    );
  }
}

typedef ReadChangeBack = void Function(String, List<Offset>);

class QrReaderViewController {
  final int id;
  final MethodChannel _channel;

  QrReaderViewController(this.id)
      : _channel = MethodChannel('br.com.flutterando.ez_qr.reader_view_$id') {
    _channel.setMethodCallHandler(_handleMessages);
  }

  ReadChangeBack onQrBack;

  Future _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'onQRCodeRead':
        final points = <Offset>[];
        if (call.arguments.containsKey('points')) {
          final pointsStrs = call.arguments['points'];
          for (String point in pointsStrs) {
            final offset = point.split(',');
            points.add(
              Offset(
                double.parse(offset.first),
                double.parse(offset.last),
              ),
            );
          }
        }

        onQrBack(call.arguments['text'], points);
        break;
    }
  }

  // Turn on the flashlight
  Future<bool> setFlashlight() async {
    return await _channel.invokeMethod('flashlight') as bool;
  }

  // Camera Focus
  Future cameraFocus() async {
    debugPrint('aea');
    return await _channel.invokeMethod('focus');
  }

  // Start scanning
  Future startCamera(ReadChangeBack onQrBack) async {
    this.onQrBack = onQrBack;
    return _channel.invokeMethod('startCamera');
  }

  // End scan code
  Future stopCamera() async {
    return _channel.invokeMethod('stopCamera');
  }
}
