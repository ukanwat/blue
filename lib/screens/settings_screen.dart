// Dart imports:
import 'package:blue/screens/rewards_screen.dart';
import 'package:universal_platform/universal_platform.dart';
import 'dart:ui';
import 'package:blue/constants/app_colors.dart';
// Flutter imports:
import 'package:blue/constants/strings.dart';
import 'package:blue/models/user.dart';
import 'package:blue/screens/settings/about/community_guidelines.screen.dart';
import 'package:blue/screens/settings/about/faqs.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/custom_image.dart';
import 'package:blue/widgets/dialogs/show_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:device_info/device_info.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:package_info/package_info.dart';

// Project imports:
import 'package:blue/main.dart';
import 'package:blue/screens/settings/about/license_screen.dart';
import 'package:blue/screens/settings/about/privacy_policy_screen.dart';
import 'package:blue/screens/settings/about/terms_of_service_screen.dart';
import 'package:blue/screens/settings/feedback/give_a_suggestion_screen.dart';
import 'package:blue/screens/settings/feedback/report_a_bug_screen.dart';
import 'package:blue/screens/settings/general/account_screen.dart';
import 'package:blue/screens/settings/general/appearance_screen.dart';
import 'package:blue/screens/settings/general/collections_screen.dart';
import 'package:blue/screens/settings/general/drafts_screen.dart';
import 'package:blue/screens/settings/notification/email_notifications_screen.dart';
import 'package:blue/screens/settings/notification/push_notifications_screen.dart';
import 'package:blue/screens/settings/privacy/activity_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screen.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/widgets/progress.dart';
import 'package:blue/widgets/settings_widgets.dart';
import 'package:in_app_review/in_app_review.dart';

final InAppReview inAppReview = InAppReview.instance;

class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _deviceData;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.release': build.version.release,
      'brand': build.brand,
      'device': build.device,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'userId': currentUser.userId,
      'version': 1.0, //TODO
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'utsname.release': data.utsname.release,
      'utsname.version': data.utsname.version,
      'userId': currentUser.id,
      'version': 1.0,
      //TODO
    };
  }

  User user;
  @override
  void didChangeDependencies() {
    User _user = ModalRoute.of(context).settings.arguments as User;
    user = _user;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  getInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  PackageInfo packageInfo;
  @override
  Widget build(BuildContext context) {
    bool dark = Theme.of(context).iconTheme.color == Colors.white;
    print(user.avatarUrl);
    print(user.photoUrl);
    return Scaffold(
      backgroundColor: dark
          ? Theme.of(context).backgroundColor
          : Theme.of(context).canvasColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  color: dark
                      ? Theme.of(context).backgroundColor
                      : Color.fromRGBO(245, 245, 245, 1),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          FluentIcons.chevron_left_16_filled,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        'Settings',
                        style: TextStyle(
                            fontFamily: 'Stark Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  )),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  color: dark
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.pushNamed(context, AccountScreen.routeName);
                      },
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CircleAvatar(
                              minRadius: 30,
                              maxRadius: 30,
                              backgroundImage: CachedNetworkImageProvider(
                                  user.photoUrl == null
                                      ? (user.photoUrl)
                                      : (user.avatarUrl ??
                                          Strings.emptyAvatarUrl)),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 24,
                                    fontFamily: 'Stark Sans'),
                              ),
                              Text(
                                'Account',
                                style:
                                    TextStyle(fontSize: 15, color: Colors.grey),
                              )
                            ],
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child:
                                Icon(FluentIcons.ios_chevron_right_20_filled),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              settingsSectionTitle(
                  'General ⚙️',
                  Icon(
                    FluentIcons.content_settings_20_regular,
                    color: AppColors.blue,
                  ),
                  context),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  color: dark
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        settingsPageNavigationTile(
                            context, 'Appearance', AppearanceScreen.routeName),
                        settingsPageNavigationTile(context, 'Collections',
                            CollectionsScreen.routeName),
                        settingsPageNavigationTile(
                            context, 'Drafts', DraftsScreen.routeName,
                            removeBorder: true),
                        settingsPageNavigationTile(
                            context, 'Rewards', RewardsScreen.routeName),
                      ],
                    ),
                  ),
                ),
              ),

              settingsSectionTitle(
                  'Notifications 🔔',
                  Icon(
                    FluentIcons.alert_20_regular,
                    color: AppColors.blue,
                  ),
                  context),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  color: dark
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        settingsPageNavigationTile(
                            context,
                            'Email Notifications',
                            EmailNotificationsScreen.routeName),
                        settingsPageNavigationTile(
                            context,
                            'Push Notifications',
                            PushNotificationsScreen.routeName,
                            removeBorder: true),
                      ],
                    ),
                  ),
                ),
              ),

              settingsSectionTitle(
                  'Privacy 👮‍♀️',
                  Icon(
                    FluentIcons.person_20_regular,
                    color: AppColors.blue,
                  ),
                  context),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  color: dark
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        settingsPageNavigationTile(
                            context, 'Safety', SafetyScreen.routeName),
                        settingsPageNavigationTile(
                            context, 'Activity', ActivityScreen.routeName,
                            removeBorder: true),
                      ],
                    ),
                  ),
                ),
              ),

              // Divider(
              //   thickness: 6,
              //   height: 20,
              //   color: Theme.of(context).canvasColor,
              // ),
              settingsSectionTitle(
                  'Support & Feedback 📞',
                  Icon(FluentIcons.person_support_20_regular,
                      color: AppColors.blue),
                  context),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  color: dark
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        settingsActionTile(context, 'Give a Suggestion', () {
                          Navigator.of(context)
                              .pushNamed(GiveASuggestionScreen.routeName);
                        }, FluentIcons.person_feedback_24_regular),
                        settingsActionTile(context, 'Report a Bug', () {
                          Navigator.of(context)
                              .pushNamed(ReportABugScreen.routeName);
                        }, FluentIcons.bug_24_regular),
                        settingsActionTile(context, 'FAQ', () {
                          Navigator.of(context).pushNamed(FAQScreen.routeName);
                        }, FluentIcons.chat_bubbles_question_24_regular),
                        settingsActionTile(context, 'Get Help', () async {
                          Map<String, dynamic> deviceData;
                          try {
                            if (UniversalPlatform.isAndroid) {
                              deviceData = _readAndroidBuildData(
                                  await deviceInfoPlugin.androidInfo);
                            } else if (UniversalPlatform.isIOS) {
                              deviceData = _readIosDeviceInfo(
                                  await deviceInfoPlugin.iosInfo);
                            }
                          } on PlatformException {
                            deviceData = <String, dynamic>{
                              'Error:': 'Failed to get platform version.'
                            };

                            return;
                          }
                          _deviceData = deviceData;

                          final Email email = Email(
                            body: UniversalPlatform.isIOS
                                ? '...\n\nStark User ID: ${Boxes.currentUserBox.get('user_id')}\nApp version: ${_deviceData['version']}\nDevice: ${_deviceData['name']}\nModel: ${_deviceData['model']}\nManufacturer: ${[
                                    'manufacturer'
                                  ]}\nOS Version: ${_deviceData['utsname.version']}'
                                : '...\n\nStark User ID: ${Boxes.currentUserBox.get('user_id')}\nApp version: ${_deviceData['version']}\nModel: ${_deviceData['model']}\nOS Version: ${_deviceData['version.release']}',
                            subject: 'Stark Support\n[Android]',
                            recipients: ['support@stark.social'],
                            isHTML: false,
                          );

                          try {
                            await FlutterEmailSender.send(email);
                          } catch (e) {
                            snackbar(e.message, context, color: Colors.red);
                          }
                        }, FluentIcons.chat_help_24_regular,
                            removeBorder: true),
                      ],
                    ),
                  ),
                ),
              ),
              settingsSectionTitle(
                  'About ℹ️',
                  Icon(
                    FluentIcons.info_24_regular,
                    color: AppColors.blue,
                  ),
                  context),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  color: dark
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        settingsActionTile(context, 'Rate Our App', () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return ShowDialog(
                                  title: 'App Review',
                                  description:
                                      'Would you like to give us 5 stars?',
                                  middleButtonText: 'No',
                                  topButtonText: 'Yes',
                                  middleButtonFunction: () {
                                    Navigator.pop(context);
                                  },
                                  topButtonFunction: () async {
                                    Navigator.pop(context);
                                    if (await inAppReview.isAvailable()) {
                                      inAppReview.requestReview();
                                      Hasura.updateUser(reviewed: true);
                                    }
                                  },
                                );
                              });
                        }, FluentIcons.star_24_regular),
                        settingsActionTile(
                          context,
                          'Terms of Use',
                          () {
                            Navigator.of(context)
                                .pushNamed(TermsOfServiceScreen.routeName);
                          },
                          FluentIcons.textbox_24_regular,
                        ),
                        settingsActionTile(context, 'Privacy policy', () {
                          Navigator.of(context)
                              .pushNamed(PrivacyPolicyScreen.routeName);
                        }, FlutterIcons.lock_outline_mco),
                        settingsActionTile(context, 'Community Guidelines', () {
                          Navigator.of(context)
                              .pushNamed(CommunityGuidelinesScreen.routeName);
                        }, FluentIcons.book_open_20_regular,
                            removeBorder: true),
                        settingsActionTile(context, 'Acknowledgements', () {
                          Navigator.of(context)
                              .pushNamed(LicenseScreen.routeName);
                        }, FluentIcons.ribbon_24_regular, removeBorder: true),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.only(top: 12),
                width: double.infinity,
                color: dark
                    ? Theme.of(context).backgroundColor
                    : Theme.of(context).canvasColor,
                height: 30,
                child: Center(
                  child: Text(
                    'v${packageInfo == null ? ' ' : '${packageInfo.version}' + '+' + '${packageInfo.buildNumber}'}',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              Container(
                color: dark
                    ? Theme.of(context).backgroundColor
                    : Theme.of(context).canvasColor,
                child: Center(
                    child: Text(
                  'Stark',
                  style: TextStyle(
                      fontFamily: 'Techna Sans Regular', fontSize: 20),
                )),
              ),
              Container(
                color: dark
                    ? Theme.of(context).backgroundColor
                    : Theme.of(context).canvasColor,
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
