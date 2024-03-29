// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:blue/env.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gradients/flutter_gradients.dart';

class AppColors {
  static Color navBar = Color.fromRGBO(10, 10, 15, 1);
  static const Color navBarLight = Color.fromRGBO(255, 255, 255, 1);
  static const Color navBarDark = Color.fromRGBO(10, 10, 15, 1);
  static Color blue = Color.fromRGBO(20, 90, 190, 1);
  static const Color blueDark = Color.fromRGBO(1, 160, 255, 1);
  static const Color blueLight = Color.fromRGBO(20, 90, 190, 1);

  List<Color> clrList = [
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
    Colors.teal,
    Colors.tealAccent,
    Colors.indigo,
    Colors.indigoAccent
  ];
  Random _random = new Random();
  Color get rndColor {
    return clrList[_random.nextInt(clrList.length)];
  }

  Gradient get rndGradient {
    return FlutterGradients.findByName(FlutterGradientNames
        .values[Random().nextInt(FlutterGradientNames.values.length - 2)]);
  }
}
