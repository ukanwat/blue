import 'dart:convert';

import 'package:blue/providers/provider_widget.dart' as PW;
import 'package:blue/providers/theme.dart';
import 'package:blue/screens/all_saved_posts_screen.dart';
import 'package:blue/screens/all_topics_screen.dart';
import 'package:blue/screens/settings/general/appearance_screen.dart';
import 'package:blue/screens/sign_in_screen.dart';
import 'package:blue/screens/profile_image_crop_screen.dart';
import 'package:blue/screens/sign_in_screen.dart';
import 'package:blue/screens/sign_in_view_screen.dart';
import 'package:blue/screens/tabs_screen.dart';
import 'package:blue/screens/tag_screen.dart';
import 'package:blue/screens/search_tag_screen.dart';
import 'package:blue/screens/select_topic_screen.dart';
import 'package:blue/screens/settings/about/acknowledgements_screen.dart';
import 'package:blue/screens/settings/advanced_settings/autoplay_screen.dart';
import 'package:blue/screens/settings/advanced_settings/content_cache_screen.dart';
import 'package:blue/screens/settings/advanced_settings/gestures_screen.dart';
import 'package:blue/screens/settings/feedback/give_a_suggestion_screen.dart';
import 'package:blue/screens/settings/feedback/report_a_bug_screen.dart';
import 'package:blue/screens/settings/general/account_screen.dart';
import 'package:blue/screens/settings/general/account_screens/deactivate_account_screen.dart';
import 'package:blue/screens/settings/general/account_screens/logins.dart';
import 'package:blue/screens/settings/general/account_screens/password_screen.dart';
import 'package:blue/screens/settings/general/collection_screens/create_collection_screen.dart';
import 'package:blue/screens/settings/general/collections_screen.dart';
import 'package:blue/screens/settings/general/drafts_screen.dart';
import 'package:blue/screens/settings/general/appearance_screen.dart';
import 'package:blue/screens/settings/notification/email_notifications_screen.dart';
import 'package:blue/screens/settings/notification/push_notifications_screen.dart';
import 'package:blue/screens/settings/privacy/activity_screen.dart';
import 'package:blue/screens/settings/privacy/activity_screens/account_privacy_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screens/blocked_accounts_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screens/muted_accounts_screen.dart';
import 'package:blue/screens/topic_posts_screen.dart';
import 'package:blue/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blue/screens/chat_info_screen.dart';
import 'package:blue/screens/gifs_screen.dart';

import 'package:blue/screens/chat_messages_screen.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/search_screen.dart';
import './screens/edit_profile_screen.dart';
import './screens/home.dart';
import './screens/post_screen.dart';
import './screens/comments_screen.dart';
import './screens/settings_screen.dart';
import 'models/user.dart';
import 'screens/settings/general/account_screens/email_screen.dart';

// import 'package:path_provider/path_provider.dart';
// import 'package:hive/hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await getCurrentUser();
await getPreferences();
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//     statusBarColor: Colors.transparent,
//   statusBarIconBrightness: Brightness.dark         ,            //TODO
//   statusBarBrightness: Brightness.dark
//  ));
  runApp(MyApp());
}
Future getPreferences()async{
   SharedPreferences preferences = await SharedPreferences.getInstance();
    try{ accountType = preferences.getString('accountType');}
    catch(e){
      print(e);
    }
  
}
Future getCurrentUser()async{
  
  SharedPreferences preferences = await SharedPreferences.getInstance();
  try{
  Map currentUserMap = json.decode(preferences.get('currentUser')) ;
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

  print(currentUser.id);}
catch(e){
  print(e);

}
  
}
User currentUser;
String accountType;
class MyApp extends StatelessWidget {
  
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
          theme:notifier.darkTheme == true? ThemeData(
            accentColor: Colors.white,
          
            cardColor: Color.fromRGBO(50, 50, 50, 1),
            canvasColor: Color.fromRGBO(32, 32, 32, 1),
            primaryColor: Colors.blue,
            backgroundColor: Color.fromRGBO(10, 10, 10, 1),
            textTheme: Typography.whiteMountainView,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            unselectedWidgetColor: Colors.white,
          ):ThemeData(
              accentColor: Colors.grey,
          
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
              ),
          darkTheme: notifier.darkTheme == false? ThemeData(
              accentColor: Colors.grey,
          
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
              ):ThemeData(
            accentColor: Colors.white,
          
            cardColor: Color.fromRGBO(50, 50, 50, 1),
            canvasColor: Color.fromRGBO(32, 32, 32, 1),
            primaryColor: Colors.blue,
            backgroundColor: Color.fromRGBO(10, 10, 10, 1),
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
                    builder: (_) => AllTopicsScreen(), settings: settings);
                break;
            }
             return CupertinoPageRoute(
                    builder: (_) => HomeController(), settings: settings);
          
           
          },
          routes: {
            TabsScreen.routeName: (ctx) => TabsScreen(),
              SignInScreen.anonymousSignInRouteName: (ctx) =>SignInScreen(authFormType: AuthFormType.anonymous,),
        SignInScreen.signInRouteName: (ctx) =>SignInScreen(authFormType: AuthFormType.signIn,),
          SignInScreen.signUpRouteName: (ctx) =>SignInScreen(authFormType: AuthFormType.signUp,),
            SignInScreen.googleSignInRouteName: (ctx) =>SignInScreen(authFormType: AuthFormType.googleSignIn,),
            SearchScreen.routeName: (ctx) => SearchScreen(),
            EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
            PostScreen.routeName: (ctx) => PostScreen(),
            CommentsScreen.routeName: (ctx) => CommentsScreen(),
            ChatMessagesScreen.routeName: (ctx) => ChatMessagesScreen(),
            SelectTopicScreen.routeName: (ctx) => SelectTopicScreen(),
            TopicPostsScreen.routeName: (ctx) => TopicPostsScreen(),
            AllSavedPostsScreen.routeName: (ctx) => AllSavedPostsScreen(),
            SettingsScreen.routeName: (ctx) => SettingsScreen(),
            ChatInfoScreen.routeName: (ctx) => ChatInfoScreen(),
            GIFsScreen.routeName: (ctx) => GIFsScreen(),
            ProfileImageCropScreen.routeName: (ctx) => ProfileImageCropScreen(),
            SearchTagScreen.routeName: (ctx) => SearchTagScreen(),
            TagScreen.routeName: (ctx) => TagScreen(),
            AccountScreen.routeName: (ctx) => AccountScreen(),
            AppearanceScreen.routeName: (ctx) => AppearanceScreen(),
            CollectionsScreen.routeName: (ctx) => CollectionsScreen(),
            DraftsScreen.routeName: (ctx) => DraftsScreen(),
            PushNotificationsScreen.routeName: (ctx) => PushNotificationsScreen(),
            EmailNotificationsScreen.routeName: (ctx) =>
                EmailNotificationsScreen(),
            AutoplayScreen.routeName: (ctx) => AutoplayScreen(),
            ContentCacheScreen.routeName: (ctx) => ContentCacheScreen(),
            GesturesScreen.routeName: (ctx) => GesturesScreen(),
            SafetyScreen.routeName: (ctx) => SafetyScreen(),
            ActivityScreen.routeName: (ctx) => ActivityScreen(),
            GiveASuggestionScreen.routeName: (ctx) => GiveASuggestionScreen(),
            ReportABugScreen.routeName: (ctx) => ReportABugScreen(),
            AcknowledgementsScreen.routeName: (ctx) => AcknowledgementsScreen(),
            EmailScreen.routeName: (ctx) => EmailScreen(),
            PasswordScreen.routeName: (ctx) => PasswordScreen(),
            DeactivateAccountScreen.routeName: (ctx) => DeactivateAccountScreen(),
            LoginsScreen.routeName: (ctx) => LoginsScreen(),
            CreateCollectionScreen.routeName: (ctx) => CreateCollectionScreen(),
            BlockedAccountsScreen.routeName: (ctx) => BlockedAccountsScreen(),
            MutedAccountsScreen.routeName: (ctx) => MutedAccountsScreen(),
            AccountPrivacyScreen.routeName: (ctx) => AccountPrivacyScreen(),
          }),
    ); } ,
          ),
    );
  }
}

class HomeController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService auth = PW.Provider.of(context).auth;
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData;
          return signedIn  &&  currentUser != null ? TabsScreen() : SignInViewScreen();
        }
        return CircularProgressIndicator();
      },
    );
  }
}