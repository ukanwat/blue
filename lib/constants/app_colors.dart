// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gradients/flutter_gradients.dart';

class AppColors {
  static const navBar = Color.fromRGBO(10, 10, 15, 1);

  List<Color> _clrList = [
    Color(0xFFFFBC42),
    Color(0xFFF55D3E),
    Color(0xFF00CC66),
    Color(0xFFD2103A),
    Color(0xFF027BCE),
    Color(0xFF8338ec),
    Color(0xFF52b788),
    Colors.amber,
    Colors.amberAccent,
    Colors.blue,
    Colors.blueGrey,
    Colors.cyan,
  ];
  Random _random = new Random();
  Color get rndColor {
    return _clrList[_random.nextInt(_clrList.length)];
  }

  Gradient get rndGradient {
    return FlutterGradients.findByName(FlutterGradientNames
        .values[Random().nextInt(FlutterGradientNames.values.length - 2)]);
  }
}
