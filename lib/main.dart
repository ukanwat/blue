// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'package:blue/screens/settings/about/acknowledgements_screen.dart';
import 'package:blue/screens/settings/about/privacy_policy_screen.dart';
import 'package:blue/screens/settings/about/terms_of_service_screen.dart';
import 'package:blue/screens/settings/feedback/give_a_suggestion_screen.dart';
import 'package:blue/screens/settings/feedback/report_a_bug_screen.dart';
import 'package:blue/screens/settings/general/account_screen.dart';
import 'package:blue/screens/settings/general/account_screens/deactivate_account_screen.dart';
import 'package:blue/screens/settings/general/account_screens/logins.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await getCurrentUser();                                              ////////check all, do all on login to0
  await getPreferences();
  await openBoxes();              

 
  uploadTagsInfo();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //TODO
      systemNavigationBarColor: Colors.black,
      systemNavigationBarDividerColor: Colors.grey[900],
      systemNavigationBarIconBrightness: Brightness.light));
  runApp(MyApp());
}

 Box voteBox;
 
   loadVotes()async {
     if(currentUser.id == null)
     return;
     if(PreferencesUpdate().getBool('votes_downloaded',def: false))
     return;
    QuerySnapshot query;
     try{
query = await postsVotersRef.doc(currentUser.id).collection('userVotes').
        get(GetOptions(source: Source.server));
     }catch(e){
       return;
     }
        
        if(query.docs.length != 0)
        query.docs.forEach((doc) {
          List<String> ids =  doc.data()['ids'];

          List<bool> votes =  doc.data()['votes'];
         for(int i = 0; i< ids.length; i++){
            voteBox.put(ids,votes);
         }
});

         PreferencesUpdate().updateBool('votes_downloaded', true);
       
  }
uploadTagsInfo() {
  DateTime nowTime = DateTime.now();
  DateTime todayTime =
      DateTime.parse("${nowTime.year}-${nowTime.month}-${nowTime.day}");
  String openedTagsInfo = preferences.getString('tags_open_info');
  Map openedTagsMap = {};
  if(openedTagsInfo == null){
    preferences.setString('tags_open_info',json.encode({}));
  }else
 openedTagsMap = json.decode(openedTagsInfo);
  print(todayTime);
  String lastTagsInfoUploaded =
      preferences.getString('last_tags_info_uploaded');
      if(lastTagsInfoUploaded == null){
         preferences.setString('last_tags_info_uploaded',DateTime.now().toString());
         lastTagsInfoUploaded =
      preferences.getString('last_tags_info_uploaded');
      }
  if (!todayTime.isAtSameMomentAs(DateTime.parse(lastTagsInfoUploaded))) {
    openedTagsMap.forEach((key, value) {
      if (DateTime.parse(key)
          .isAtSameMomentAs(DateTime.parse(lastTagsInfoUploaded))) {
        openedTagsRef.doc(currentUser.id).set(
            {DateTime.parse(key).toString(): value}, SetOptions(merge: true));
      }
    });
     preferences.setString('last_tags_info_uploaded', todayTime.toString());
  }
}

Future getPreferences() async {
  if(currentUser == null)
  return;
  preferences = await SharedPreferences.getInstance();
  try {
    accountType = preferences.getString('accountType');
  } catch (e) {
    print(e);
  }
  if (preferences.getStringList('followed_tags') == null) {
    await preferences.setStringList('followed_tags', []);
  }
}

Future getCurrentUser() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  try {
    Map currentUserMap = json.decode(preferences.get('currentUser'));
    print(currentUserMap);
    currentUser = User(
      id: currentUserMap['id'],
      bio: currentUserMap['bio'],
      displayName: currentUserMap['displayName'],
      email: currentUserMap['email'],
      photoUrl: currentUserMap['photoUrl'],
      username: currentUserMap['username'],
      website: currentUserMap['website'],
    );

    print(currentUser.id);
  } catch (e) {
    print(e);
  }

}
  bool   boxesOpened ;
Future openBoxes() async {
    if(currentUser == null)
  return;
    if(currentUser == null)
  return;
  try{
 var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  voteBox =  await Hive.openBox('votes');
  boxesOpened = true;
    loadVotes();
  }catch(e){
    
  }
 

}
SharedPreferences preferences;
User currentUser;
String accountType;

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

Future<dynamic> myBackgroundHandler(Map<String, dynamic> message) {
  return MyAppState()._showNotification(message);
}
class MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
 
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          return PW.Provider(
            auth: AuthService(),
            child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Scrible',
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
                    case AcknowledgementsScreen.routeName:
                      return PageTransition(
                          child: AcknowledgementsScreen(),
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
                  SignInScreen.anonymousSignInRouteName: (ctx) => SignInScreen(
                        authFormType: AuthFormType.anonymous,
                      ),
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
                  CommentsScreen.routeName: (ctx) => CommentsScreen(),
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
                  DeactivateAccountScreen.routeName: (ctx) =>
                      DeactivateAccountScreen(),
                  LoginsScreen.routeName: (ctx) => LoginsScreen(),
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


    Future _showNotification(Map<String, dynamic> message) async {                    //TODO for IOS
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel desc', 
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics =
        new NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'new message arived',
      'i want ${message['data']['title']} for ${message['data']['price']}',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  Future selectNotification(String payload) async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

    
  getTokenz() async {
    String token = await _firebaseMessaging.getToken();
    print(token);
  }

  // Future selectNotification(String payload) async {
  //   await flutterLocalNotificationsPlugin.cancelAll();
  // }

  @override
  void initState() {
      String host = Platform.isAndroid ? '10.0.2.2:8080' : 'localhost:8080';

Settings(   host: host,
      sslEnabled: false,
      persistenceEnabled: false,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
// final IOSInitializationSettings initializationSettingsIOS =
//     IOSInitializationSettings(
//         onDidReceiveLocalNotification: onDidReceiveLocalNotification);
// final MacOSInitializationSettings initializationSettingsMacOS =
//     MacOSInitializationSettings();
final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,iOS: null
    // iOS: initializationSettingsIOS,
    // macOS: initializationSettingsMacOS
    );
flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onSelectNotification: selectNotification);
    super.initState();

    _firebaseMessaging.configure(
      onBackgroundMessage: myBackgroundHandler,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('new message arived'),
                content: Text(
                    'i want ${message['notification']['title']} for ${message['notification']['body']}'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },);
      },
    );

    getTokenz();
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
          final bool signedIn = snapshot.hasData;
          return signedIn && currentUser != null
              ? TabsScreen()
              : SignInViewScreen();
        }
        return CircularProgressIndicator();
      },
    );
  }
}
