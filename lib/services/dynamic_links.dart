// Package imports:
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/material.dart';
import '../screens/comments_screen.dart';
import '../screens/home.dart';
import '../widgets/post.dart';
class DynamicLinksService {
  static Future<String> createDynamicLink(String parameter) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print(packageInfo.packageName);
    String uriPrefix = "https://scrible.page.link";

    final DynamicLinkParameters parameters = DynamicLinkParameters(        //TODO
      uriPrefix: uriPrefix,
      link: Uri.parse('https://scrible.com/$parameter'),
      androidParameters: AndroidParameters(
        packageName: packageInfo.packageName,
      ),
      iosParameters: IosParameters(
        bundleId: packageInfo.packageName,
        minimumVersion: packageInfo.version,
        appStoreId: '123456789',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'example-promo',
        medium: 'social',
        source: 'orkut',
      ),
      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
        providerToken: '123456',
        campaignToken: 'example-promo',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Dynamic link',
          description: 'This link works whether app is installed or not!',
          imageUrl: Uri.parse(
              "https://www.google.com")),
    );

    // final Uri dynamicUrl = await parameters.buildUrl();
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl.toString();
  }

  static Future initDynamicLinks(BuildContext context) async {
    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();

    handleDynamicLink(data,context);

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          handleDynamicLink(dynamicLink,context);
        }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  static handleDynamicLink(PendingDynamicLinkData data,BuildContext context) async {
    final Uri deepLink = data?.link;

    if (deepLink == null) {
      return;
    }
    print(deepLink);
    if (deepLink.pathSegments.contains('post')) {
      var postId = deepLink.queryParameters['id'];
      var doc= await postsRef.doc(postId).get();
      if (postId != null) {

        Navigator.of(context).pushNamed(CommentsScreen.routeName,arguments: Post.fromDocument(doc.data(),commentsShown: true,isCompact: false,));


      }
    }
  }
}
