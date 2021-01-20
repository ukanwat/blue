// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/widgets/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
  await Firebase.initializeApp();
  await getCurrentUser();

 
  await Boxes.openBoxes();
 if(userSignedIn){
    await getPreferences();
  }


  try {
     if(userSignedIn){  uploadTagsInfo();
  }
  
  } catch (e) {}
  
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarDividerColor: Colors.grey[900],
   ));
  runApp(MyApp());
}
bool userSignedIn = false;
loadVotes() async {
  if(!userSignedIn){
return;
  }
  if (PreferencesUpdate().getBool('votes_downloaded', def: false)) return;
  QuerySnapshot query;
  try {
    query = await postsVotersRef
        .doc(currentUser.id)
        .collection('userVotes')
        .get(GetOptions(source: Source.server));
  } catch (e) {
    return;
  }

  if (query.docs.length != 0)
    query.docs.forEach((doc) {
      List<String> ids = doc.data()['ids'];

      List<bool> votes = doc.data()['votes'];
      for (int i = 0; i < ids.length; i++) {
        Boxes.voteBox.put(ids, votes);
      }
    });

  PreferencesUpdate().updateBool('votes_downloaded', true);
}

uploadTagsInfo() {
  DateTime nowTime = DateTime.now();
  String _nowMonth =
      nowTime.month < 10 ? '0${nowTime.month}' : '${nowTime.month}';
  String _nowDay = nowTime.day < 10 ? '0${nowTime.day}' : '${nowTime.day}';
  DateTime todayTime = DateTime.parse("${nowTime.year}-$_nowMonth-$_nowDay");
  Map openedTagsMap = {};
  try {
    String openedTagsInfo = PreferencesUpdate().getString('tags_open_info');

    if (openedTagsInfo == null) {
      PreferencesUpdate().updateString('tags_open_info', json.encode({}));
    } else
      openedTagsMap = json.decode(openedTagsInfo);
  } catch (e) {}

  print(todayTime);
  String lastTagsInfoUploaded =
      PreferencesUpdate().getString('last_tags_info_uploaded');
  if (lastTagsInfoUploaded == null) {
    PreferencesUpdate()
        .updateString('last_tags_info_uploaded', DateTime.now().toString());
    lastTagsInfoUploaded =
        PreferencesUpdate().getString('last_tags_info_uploaded');
  }
  if (!todayTime.isAtSameMomentAs(DateTime.parse(lastTagsInfoUploaded))) {
    openedTagsMap.forEach((key, value) {
      if (DateTime.parse(key)
          .isAtSameMomentAs(DateTime.parse(lastTagsInfoUploaded))) {
        openedTagsRef.doc(currentUser.id).set(
            {DateTime.parse(key).toString(): value}, SetOptions(merge: true));
      }
    });
    PreferencesUpdate()
        .updateString('last_tags_info_uploaded', todayTime.toString());
  }
}

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
  userSignedIn = currentUserMap['userSignedIn']?? false;
    currentUser = User.fromDocument(currentUserMap);

     
  } catch (e) {
    print(e);
  }
}

bool boxesOpened;

User currentUser;

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
            child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Stark',
                theme: notifier.darkTheme == true
                    ? ThemeData(
                        accentColor: Colors.white,
                        textSelectionColor: Color.fromRGBO(245, 245, 245, 1),
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
                        textSelectionColor: Color.fromRGBO(51, 51, 51, 1),
                        accentColor: Colors.grey,
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
                        accentColor: Colors.grey,
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
                        dividerColor: Colors.grey,
                        textSelectionColor: Color.fromRGBO(245, 245, 245, 1),
                        accentColor: Colors.white,
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
                onGenerateRoute: (settings) {
                  switch (settings.name) {
                    case AllTopicsScreen.routeName:
                      return CupertinoPageRoute(
                          builder: (_) => AllTopicsScreen(),
                          settings: settings);
                      break;
                    case AboutScreen.routeName:
                      return CupertinoPageRoute(
                          builder: (_) => AboutScreen(), settings: settings);
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
                      break;
                  }
                  return CupertinoPageRoute(
                      // TODO
                      builder: (_) => HomeController(),
                      settings: settings);
                },
                routes: {
                  TabsScreen.routeName: (ctx) => TabsScreen(),
                  SignInScreen.signInRouteName: (ctx) => SignInScreen(
                        authFormType: AuthFormType.signIn,
                      ),
                  SignInScreen.signUpRouteName: (ctx) => SignInScreen(
                        authFormType: AuthFormType.signUp,
                      ),
                  SignInScreen.googleSignInRouteName: (ctx) => SignInScreen(
                        authFormType: AuthFormType.googleSignIn,
                      ),
                  SearchScreen.routeName: (ctx) => SearchScreen(),
                  EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
                  PostScreen.routeName: (ctx) => PostScreen(),
                  VerifyEmailScreen.routeName: (ctx) => VerifyEmailScreen(),
                  ChatMessagesScreen.routeName: (ctx) => ChatMessagesScreen(),
                  SelectTopicScreen.routeName: (ctx) => SelectTopicScreen(),
                  AllSavedPostsScreen.routeName: (ctx) => AllSavedPostsScreen(),
                  ChatInfoScreen.routeName: (ctx) => ChatInfoScreen(),
                  GIFsScreen.routeName: (ctx) => GIFsScreen(),
                  ProfileImageCropScreen.routeName: (ctx) =>
                      ProfileImageCropScreen(),
                  SearchTagScreen.routeName: (ctx) => SearchTagScreen(),
                  TagScreen.routeName: (ctx) => TagScreen(),
                  CollectionPostsScreen.routeName: (ctx) =>
                      CollectionPostsScreen(),
                  ExplorePostsScreen.routeName: (ctx) => ExplorePostsScreen(),
                  EmailScreen.routeName: (ctx) => EmailScreen(),
                  PasswordScreen.routeName: (ctx) => PasswordScreen(),
                  DeactivateAccountScreen.routeName: (ctx) => DeactivateAccountScreen(),
                  CreateCollectionScreen.routeName: (ctx) =>
                      CreateCollectionScreen(),
                  BlockedAccountsScreen.routeName: (ctx) =>
                      BlockedAccountsScreen(),
                  MutedAccountsScreen.routeName: (ctx) => MutedAccountsScreen(),
                  PrivacyPolicyScreen.routeName: (ctx) => PrivacyPolicyScreen(),
                  TermsOfServiceScreen.routeName: (ctx) =>
                      TermsOfServiceScreen(),
                  LicenseScreen.routeName: (ctx) => LicenseScreen(),
                  PackageLicensesScreen.routeName: (ctx) =>
                      PackageLicensesScreen(),
                }),
          );
        },
      ),
    );
  }
}
class HomeController extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Boxes.currentUserBox.put('id', 9);
    
    final AuthService authenticate = PW.Provider.of(context).auth;
    return StreamBuilder<auth.User>(
      stream: authenticate.onAuthStateChanged,
      builder: (context, AsyncSnapshot<auth.User> snapshot) {
        if (AuthService.verifyingEmail) {
          return VerifyEmailScreen();
        }
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data != null) {
          snapshot.data.getIdTokenResult(true).then((value) {
              print(value.token);
              Hasura.jwtToken = value.token;
              
            });
          }
          final bool _signedIn = snapshot.hasData;
          return _signedIn & (userSignedIn?? false) 
              ? TabsScreen()
              : SignInViewScreen();
        }
        return circularProgress();
      },
    );
  }
}
