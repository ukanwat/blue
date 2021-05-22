// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:blue/constants/app_colors.dart';
import 'package:blue/models/hive_data_model.dart';
import 'package:blue/providers/verify_email.dart';
import 'package:blue/screens/email_sign_in_screen.dart';
import 'package:blue/screens/empty_text_screen.dart';
import 'package:blue/screens/follows_screen.dart';
import 'package:blue/screens/show_screen.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/global_network/connectivity_status.dart';
import 'package:blue/services/global_network/network_connection.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/push_notifications.dart';
import 'package:blue/widgets/progress.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:blue/providers/provider_widget.dart' as PW;
import 'package:blue/providers/theme.dart';
import 'package:blue/screens/about_screen.dart';
import 'package:blue/screens/all_saved_posts_screen.dart';
import 'package:blue/screens/all_topics_screen.dart';
import 'package:blue/screens/chat_info_screen.dart';
import 'package:blue/screens/chat_messages_screen.dart';
import 'package:blue/screens/collection_posts_screen.dart';
import 'package:blue/screens/explore_posts_screen.dart';
import 'package:blue/screens/gifs_screen.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/screens/license_screen.dart';
import './screens/set_name_screen.dart';
import 'package:blue/screens/package_licenses_screen.dart';
import 'package:blue/screens/profile_image_crop_screen.dart';
import 'package:blue/screens/search_tag_screen.dart';
import 'package:blue/screens/select_topic_screen.dart';
import 'package:blue/screens/settings/about/privacy_policy_screen.dart';
import 'package:blue/screens/settings/about/terms_of_service_screen.dart';
import 'package:blue/screens/settings/feedback/give_a_suggestion_screen.dart';
import 'package:blue/screens/settings/feedback/report_a_bug_screen.dart';
import 'package:blue/screens/settings/general/account_screen.dart';
import 'package:blue/screens/settings/general/account_screens/deactivate_account_screen.dart';
import 'package:blue/screens/settings/general/account_screens/password_screen.dart';
import 'package:blue/screens/settings/general/appearance_screen.dart';
import 'package:blue/screens/settings/general/collection_screens/create_collection_screen.dart';
import 'package:blue/screens/settings/general/collections_screen.dart';
import 'package:blue/screens/settings/general/drafts_screen.dart';
import 'package:blue/screens/settings/notification/email_notifications_screen.dart';
import 'package:blue/screens/settings/notification/push_notifications_screen.dart';
import 'package:blue/screens/settings/privacy/activity_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screens/blocked_accounts_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screens/muted_accounts_screen.dart';
import 'package:blue/screens/sign_in_screen.dart';
import 'package:blue/screens/sign_in_view_screen.dart';
import 'package:blue/screens/tabs_screen.dart';
import 'package:blue/screens/tag_screen.dart';
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/preferences_update.dart';
import './screens/comments_screen.dart';
import './screens/edit_profile_screen.dart';
import './screens/post_screen.dart';
import './screens/search_screen.dart';
import './screens/settings_screen.dart';
import 'models/user.dart';
import 'screens/settings/general/account_screens/email_screen.dart';
import './screens/verify_email_screen.dart';
import './widgets/email_verify_dialog.dart';
import './services/push_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();
  await PushNotificationsManager().initNotif();
  var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  await getCurrentUser();

  await Boxes.openBoxes();
  Hive.registerAdapter<HiveUser>(HiveUserAdapter());
  Hive.registerAdapter<HivePost>(HivePostAdapter());
  bool dark = PreferencesUpdate().getBool('theme') == true;
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black.withOpacity(0),
      systemNavigationBarDividerColor: Colors.grey[900],
      systemNavigationBarColor: AppColors.navBar,
      systemNavigationBarIconBrightness: Brightness.light));
  runApp(MyApp());
}

bool userSignedIn = false;

Future getPreferences() async {
  if (PreferencesUpdate().getStringList('followed_tags') == null) {
    await PreferencesUpdate().updateStringList('followed_tags', []);
  }
}

Future getCurrentUser() async {
  await Boxes.openCurrentUserBox();
  try {
    Map currentUserMap = Boxes.currentUserBox.toMap();
    print(currentUserMap);
    userSignedIn = currentUserMap['userSignedIn'] ?? false;
    currentUser = User.fromDocument(currentUserMap);
  } catch (e) {
    print(e);
  }
}

bool boxesOpened;

User currentUser;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
Widget buildError(BuildContext context, FlutterErrorDetails error) {
  return Scaffold(
    body: Center(
      child: Text(
        "Error appeared.",
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(context),
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          return PW.Provider(
              auth: AuthService(),
              child: StreamProvider<ConnectivityStatus>(
                create: (BuildContext context) =>
                    ConnectivityService().connectionStatusController.stream,
                child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Stark',
                    theme: notifier.darkTheme == true
                        ? ThemeData(
                            brightness: Brightness.dark,
                            accentColor: Color(0xD11ee682),
                            textSelectionTheme: TextSelectionThemeData(
                                selectionColor:
                                    Color.fromRGBO(245, 245, 245, 1)),
                            textSelectionColor:
                                Color.fromRGBO(245, 245, 245, 1),
                            cardColor: Color.fromRGBO(50, 50, 50, 1),
                            canvasColor: Color.fromRGBO(32, 32, 32, 1),
                            primaryColor: Colors.blue,
                            backgroundColor: Color.fromRGBO(10, 10, 10, 1),
                            textTheme: Typography.whiteMountainView,
                            iconTheme: IconThemeData(
                              color: Colors.white,
                            ),
                            unselectedWidgetColor: Colors.white,
                          )
                        : ThemeData(
                            brightness: Brightness.light,
                            textSelectionColor: Color.fromRGBO(51, 51, 51, 1),
                            accentColor: Color(0xD11ee682),
                            cardColor: Color.fromRGBO(238, 238, 238, 1),
                            canvasColor: Color.fromRGBO(250, 250, 250, 1),
                            primaryColor: Colors.blue,
                            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                            textTheme: Typography.blackMountainView,
                            accentTextTheme: Typography.blackMountainView,
                            iconTheme: IconThemeData(
                              color: Colors.black,
                            ),
                            primaryIconTheme: IconThemeData(
                              color: Colors.black,
                            ),
                            primaryTextTheme: Typography.blackMountainView,
                            unselectedWidgetColor: Colors.grey[700],
                          ),
                    darkTheme: notifier.darkTheme == false
                        ? ThemeData(
                            brightness: Brightness.light,
                            accentColor: Color(0xD11ee682),
                            textSelectionColor: Color.fromRGBO(24, 24, 24, 1),
                            cardColor: Color.fromRGBO(238, 238, 238, 1),
                            canvasColor: Color.fromRGBO(250, 250, 250, 1),
                            primaryColor: Colors.blue,
                            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                            textTheme: Typography.blackMountainView,
                            iconTheme: IconThemeData(
                              color: Colors.black,
                            ),
                            primaryIconTheme: IconThemeData(
                              color: Colors.black,
                            ),
                            primaryTextTheme: Typography.blackMountainView,
                            unselectedWidgetColor: Colors.grey[700],
                          )
                        : ThemeData(
                            brightness: Brightness.dark,
                            dividerColor: Colors.grey,
                            textSelectionColor:
                                Color.fromRGBO(245, 245, 245, 1),
                            accentColor: Color(0xD11ee682),
                            accentTextTheme: Typography.whiteMountainView, //
                            primaryTextTheme: Typography.whiteMountainView, //
                            cardColor: Color.fromRGBO(50, 50, 50, 1),
                            canvasColor: Color.fromRGBO(26, 26, 26, 1),
                            primaryColor: Colors.blue,
                            backgroundColor: Color.fromRGBO(12, 12, 12, 1),
                            textTheme: Typography.whiteMountainView,
                            iconTheme: IconThemeData(
                              color: Colors.white,
                            ),
                            unselectedWidgetColor: Colors.white,
                          ),
                    home: HomeController(),
                    navigatorKey: navigatorKey,
                    // builder: (BuildContext context, Widget widget) {
                    //   ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                    //     return buildError(context, errorDetails);
                    //   };

                    //   return widget;
                    // },
                    onGenerateRoute: (settings) {
                      switch (settings.name) {
                        case AllTopicsScreen.routeName:
                          return CupertinoPageRoute(
                              builder: (_) => AllTopicsScreen(),
                              settings: settings);
                          break;
                        case AboutScreen.routeName:
                          return CupertinoPageRoute(
                              builder: (_) => AboutScreen(),
                              settings: settings);
                        case SettingsScreen.routeName:
                          return PageTransition(
                              child: SettingsScreen(),
                              type: PageTransitionType.rightToLeftWithFade,
                              settings: settings);
                        case AccountScreen.routeName:
                          return PageTransition(
                              child: AccountScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);
                        case AccountScreen.routeName:
                          return PageTransition(
                              child: AccountScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);
                        case AppearanceScreen.routeName:
                          return PageTransition(
                              child: AppearanceScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);
                        case CollectionsScreen.routeName:
                          return PageTransition(
                              child: CollectionsScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);
                        case DraftsScreen.routeName:
                          return PageTransition(
                              child: DraftsScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);
                        case EmailNotificationsScreen.routeName:
                          return PageTransition(
                              child: EmailNotificationsScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);
                        case PushNotificationsScreen.routeName:
                          return PageTransition(
                              child: PushNotificationsScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);

                        case SafetyScreen.routeName:
                          return PageTransition(
                              child: SafetyScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);
                        case ActivityScreen.routeName:
                          return PageTransition(
                              child: ActivityScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);
                        case GiveASuggestionScreen.routeName:
                          return PageTransition(
                              child: GiveASuggestionScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);
                        case ReportABugScreen.routeName:
                          return PageTransition(
                              child: ReportABugScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);
                        case CommentsScreen.routeName:
                          return PageTransition(
                              child: CommentsScreen(),
                              type: PageTransitionType.rightToLeft,
                              settings: settings);
                        case ShowScreen.routeName:
                          return PageTransition(
                              child: ShowScreen(),
                              type: PageTransitionType.scale,
                              settings: settings);
                        case SetNameScreen.routeName:
                          return PageTransition(
                              child: SetNameScreen(),
                              type: PageTransitionType.scale,
                              settings: settings);
                          break;
                      }
                      return CupertinoPageRoute(
                          // TODO
                          builder: (_) => HomeController(),
                          settings: settings);
                    },
                    routes: {
                      TabsScreen.routeName: (ctx) => TabsScreen(),
                      SearchScreen.routeName: (ctx) => SearchScreen(),
                      EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
                      PostScreen.routeName: (ctx) => PostScreen(),
                      VerifyEmailScreen.routeName: (ctx) => VerifyEmailScreen(),
                      ChatMessagesScreen.routeName: (ctx) =>
                          ChatMessagesScreen(),
                      SelectTopicScreen.routeName: (ctx) => SelectTopicScreen(),
                      AllSavedPostsScreen.routeName: (ctx) =>
                          AllSavedPostsScreen(),
                      ChatInfoScreen.routeName: (ctx) => ChatInfoScreen(),
                      GIFsScreen.routeName: (ctx) => GIFsScreen(),
                      ProfileImageCropScreen.routeName: (ctx) =>
                          ProfileImageCropScreen(),
                      SearchTagScreen.routeName: (ctx) => SearchTagScreen(),
                      TagScreen.routeName: (ctx) => TagScreen(),
                      CollectionPostsScreen.routeName: (ctx) =>
                          CollectionPostsScreen(),
                      ExplorePostsScreen.routeName: (ctx) =>
                          ExplorePostsScreen(),
                      EmailScreen.routeName: (ctx) => EmailScreen(),
                      PasswordScreen.routeName: (ctx) => PasswordScreen(),
                      DeactivateAccountScreen.routeName: (ctx) =>
                          DeactivateAccountScreen(),
                      CreateCollectionScreen.routeName: (ctx) =>
                          CreateCollectionScreen(),
                      BlockedAccountsScreen.routeName: (ctx) =>
                          BlockedAccountsScreen(),
                      MutedAccountsScreen.routeName: (ctx) =>
                          MutedAccountsScreen(),
                      PrivacyPolicyScreen.routeName: (ctx) =>
                          PrivacyPolicyScreen(),
                      TermsOfServiceScreen.routeName: (ctx) =>
                          TermsOfServiceScreen(),
                      LicenseScreen.routeName: (ctx) => LicenseScreen(),
                      PackageLicensesScreen.routeName: (ctx) =>
                          PackageLicensesScreen(),
                      EmailSignInScreen.routeName: (ctx) => EmailSignInScreen(),
                      ShowScreen.routeName: (ctx) => ShowScreen(),
                      FollowsScreen.routeName: (ctx) => FollowsScreen(),
                    }),
              ));
        },
      ),
    );
  }
}

class HomeController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService authenticate = PW.Provider.of(context).auth;
    return StreamBuilder<auth.User>(
      stream: authenticate.onAuthStateChanged,
      builder: (context, AsyncSnapshot<auth.User> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data != null) {
            snapshot.data.getIdTokenResult(true).then((value) {
              print(value.token);
              Hasura.jwtToken = value.token;
            });
          }

          final bool signedIn = snapshot.hasData;
          bool finalCheck = signedIn && (userSignedIn ?? false);
          print(finalCheck);
          print(signedIn);
          print(userSignedIn);

          return finalCheck ? TabsScreen() : SignInViewScreen();
        }
        return circularProgress();
      },
    );
  }
}
