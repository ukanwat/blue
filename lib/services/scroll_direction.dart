import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/state_manager.dart';

class Scroll extends GetxController {
  final ScrollController controller;
  RxBool flag = true.obs;
  Scroll(this.controller);

  init() {
    controller.addListener(() {
      bool upDirection =
          controller.position.userScrollDirection == ScrollDirection.forward;

      // makes sure we don't call setState too much, but only when it is needed
      if (upDirection == true) {
        if (!flag.value) {
          flag.value = true;
        }
      } else {
        if (flag.value) {
          flag.value = false;
        }
      }

      flag.value = upDirection;
    });
  }
}
