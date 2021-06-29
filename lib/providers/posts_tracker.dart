// Flutter imports:
import 'package:blue/widgets/comment.dart';
import 'package:blue/widgets/comment_reply.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class PostGet extends GetxController {
  Map<int, bool> isSavedMap = {};

  setSaved(bool saved, int postId) {
    isSavedMap[postId] = saved;
    update([postId]);
  }

  getSaved(int postId) {
    return isSavedMap[postId];
  }
}
