// Package imports:
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/url_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:intl/intl.dart';
// Project imports:
import 'package:blue/main.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/home.dart';
import 'boxes.dart';

class Functions {
  handleFollowUser(
    int profileId,
  ) async {
    Boxes.followingBox.put(profileId, DateTime.now().toString());
    Hasura.insertFollow(profileId);
  }

  handleUnfollowUser(int profileId) async {
    if (Boxes.followingBox.containsKey(profileId)) {
      Boxes.followingBox.delete(profileId);
    }
    Hasura.deleteFollow(profileId);
  }

  unblockUser(Map peer) async {
    PreferencesUpdate().removeFromList('blocked_accounts', peer['peerId']);

    Hasura.deleteUserInfo(peer['peerId'], UserInfo.block);
  }

  blockUser(Map peer) async {
    Hasura.blockUser(peer['peerId']);
    PreferencesUpdate().addToList('blocked_accounts', peer['peerId']);
  }

  muteUser(Map peer) async {
    PreferencesUpdate().addToList('muted_messages', peer['peerId']);
    Hasura.muteUser(peer['peerId']);
  }

  unmuteUser(Map peer) async {
    PreferencesUpdate().removeFromList('muted_messages', peer['peerId']);
    Hasura.deleteUserInfo(peer['peerId'], UserInfo.mute);
  }

  reportUser(Map peer, Report option) async {
    Hasura.reportUser(peer['peerId'], option);
    snackbar('user reported', Get.context);
    PreferencesUpdate().addToList('reported_accounts_$option', peer['peerId']);
  }

  Future<void> _launchYoutubeVideo(String _youtubeUrl) async {
    if (_youtubeUrl != null && _youtubeUrl.isNotEmpty) {
      if (await canLaunch(_youtubeUrl)) {
        final bool _nativeAppLaunchSucceeded = await launch(
          _youtubeUrl,
          forceSafariVC: false,
          universalLinksOnly: true,
        );
        if (!_nativeAppLaunchSucceeded) {
          await launch(_youtubeUrl, forceSafariVC: true);
        }
      }
    }
  }

  launchURL(String url, BuildContext context) async {
    var urlPattern =
        r"((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$";
    if (RegExp(
      urlPattern,
    ).hasMatch(url)) {
      _launchYoutubeVideo(url);
    } else {
      showUrlBottomSheet(context, url);
    }
  }

  updateEmail() async {
    try {
      String email =
          await Hasura.getUserEmail(AuthService.firebaseAuth.currentUser.uid);
      if (email == null) {
        //TODO
      } else if (AuthService.firebaseAuth.currentUser.email != email) {
        Hasura.updateUser(email: AuthService.firebaseAuth.currentUser.email);
      }
    } catch (e) {}
  }

  static String abbreviateNumber(int value, {bool hideLess}) {
    if (hideLess == true) {
      if (value == 0 || value == null) {
        return ' ';
      } else if (value != null) {
        if (value < 0) {
          return ' ';
        }
      }
    }
    if (value > 999 && value < 99999) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    } else if (value > 99999 && value < 999999) {
      return "${(value / 1000).toStringAsFixed(0)}K";
    } else if (value > 999999 && value < 999999999) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value > 999999999) {
      return "${(value / 1000000000).toStringAsFixed(1)}B";
    } else {
      return value.toString();
    }
  }

  String date(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    String month;
    switch (tm.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }
    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "Today";
    } else if (difference.compareTo(twoDay) < 1) {
      return "Yesterday";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "Monday";
        case 2:
          return "Tuesday";
        case 3:
          return "Wednesday";
        case 4:
          return "Thurdsday";
        case 5:
          return "Friday";
        case 6:
          return "Saturday";
        case 7:
          return "Sunday";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
    return "";
  }
}
