// Flutter imports:
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/go_to.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

// Project imports:
import 'package:blue/screens/sign/set_name_screen.dart';
import 'package:blue/services/hasura.dart';
import '../screens/comments_screen.dart';
import '../widgets/post.dart';

class DynamicLinksService {
  static Future<String> createDynamicLink(String parameter) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String uriPrefix = "https://starkapp.page.link";

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      //TODO
      uriPrefix: uriPrefix,
      link: Uri.parse('https://www.stark.social/$parameter'),
      androidParameters: AndroidParameters(
        packageName: packageInfo.packageName,
      ),
      iosParameters: IosParameters(
        bundleId: packageInfo.packageName,
        minimumVersion: packageInfo.version,
        appStoreId: '1574720606',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'share',
        medium: 'social',
        source: 'stark',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Stark',
          description: '',
          imageUrl: Uri.parse(
              "https://firebasestorage.googleapis.com/v0/b/blue-cabf5.appspot.com/o/stark-wg.png?alt=media&token=ded28aaf-3bea-41e3-96b5-fa07a973ca00")),
    );

    // final Uri dynamicUrl = await parameters.buildUrl();
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl.toString();
  }

  static Future initDynamicLinks(BuildContext context) async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    handleDynamicLink(data, context);

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          handleDynamicLink(dynamicLink, context);
        },
        onError: (OnLinkErrorException e) async {});
  }

  static handleDynamicLink(
      PendingDynamicLinkData data, BuildContext context) async {
    final Uri deepLink = data?.link;

    if (deepLink == null) {
      return;
    }
    if (deepLink.pathSegments.contains('post')) {
      String postId = deepLink.queryParameters['id'];
      if (Hasura.jwtToken == null) {
        AuthService.firebaseAuth.authStateChanges().first.then((user) {
          user.getIdToken(true).then((token) {
            Hasura.jwtToken = token;
          });
        });
      }
      var doc = await Hasura.getPost(int.parse(postId), link: true);
      if (postId != null) {
        Navigator.of(Get.context)
            .pushNamed(CommentsScreen.routeName, arguments: {
          'post': Post.fromDocument(
            doc,
            commentsShown: true,
            isCompact: false,
          )
        });
      }
    } else if (deepLink.pathSegments.contains('verify')) {
      // var email = deepLink.queryParameters['email'];   TODO
      // Navigator.of(context).pushNamed(SetNameScreen.routeName,
      //   arguments: {'email': email, 'provider': 'email'});
    } else if (deepLink.pathSegments.contains('user')) {
      String userId = deepLink.queryParameters['id'];
      if (Hasura.jwtToken == null) {
        AuthService.firebaseAuth.authStateChanges().first.then((user) {
          user.getIdToken(true).then((token) {
            Hasura.jwtToken = token;
          });
        });
      }

      GoTo().profileScreen(context, int.parse(userId));
    }
  }
}
