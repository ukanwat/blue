import 'package:blue/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:get/get.dart';

class Env {
  static bool newUser;
  static bool introShown = false;
  static bool darkMode = false;
  static Intro intro = Intro(
    /// You can set it true to disable animation
    noAnimation: false,
    maskColor: Theme.of(Get.context).iconTheme.color == Colors.black
        ? Colors.black.withOpacity(0.6)
        : Colors.white.withOpacity(0.3),
    stepCount: 1,
    maskClosable: true,

    /// When highlight widget is tapped.
    onHighlightWidgetTap: (introStatus) {
      print(introStatus);
    },

    /// The padding of the highlighted area and the widget
    padding: EdgeInsets.all(0),

    /// Border radius of the highlighted area
    borderRadius: BorderRadius.all(Radius.circular(4)),
    widgetBuilder: StepWidgetBuilder.useDefaultTheme(
      /// Guide page text
      texts: ['Get \$15 for every person you invite to stark'],

      /// Button text
      buttonTextBuilder: (curr, total) {
        return 'Okay';
        // return curr < total - 1 ? 'Next' : 'Finish';
      },
    ),
  );
  static reset() {
    darkMode = false;
    introShown = false;
    newUser = null;
    intro = Intro(
      /// You can set it true to disable animation
      noAnimation: false,
      maskColor: Theme.of(Get.context).iconTheme.color == Colors.black
          ? Colors.black.withOpacity(0.6)
          : Colors.white.withOpacity(0.3),
      stepCount: 1,
      maskClosable: true,

      /// When highlight widget is tapped.
      onHighlightWidgetTap: (introStatus) {
        print(introStatus);
      },

      /// The padding of the highlighted area and the widget
      padding: EdgeInsets.all(0),

      /// Border radius of the highlighted area
      borderRadius: BorderRadius.all(Radius.circular(4)),
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        /// Guide page text
        texts: ['Get \$15 for every person you invite to stark'],

        /// Button text
        buttonTextBuilder: (curr, total) {
          return 'Okay';
          // return curr < total - 1 ? 'Next' : 'Finish';
        },
      ),
    );
  }
}
