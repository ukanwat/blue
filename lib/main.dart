import 'dart:convert';

import 'package:blue/providers/provider_widget.dart' as PW;
import 'package:blue/providers/theme.dart';
import 'package:blue/screens/about_screen.dart';
import 'package:blue/screens/all_saved_posts_screen.dart';
import 'package:blue/screens/all_topics_screen.dart';
import 'package:blue/screens/collection_posts_screen.dart';
import 'package:blue/screens/explore_posts_screen.dart';
import 'package:blue/screens/license_screen.dart';
import 'package:blue/screens/package_licenses_screen.dart';
import 'package:blue/screens/settings/about/privacy_policy_screen.dart';
import 'package:blue/screens/settings/about/terms_of_service_screen.dart';
import 'package:blue/screens/settings/advanced_settings/font_screen.dart';
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
import 'package:blue/screens/settings/privacy/safety_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screens/blocked_accounts_screen.dart';
import 'package:blue/screens/settings/privacy/safety_screens/muted_accounts_screen.dart';
import 'package:blue/screens/category_posts_screen.dart';
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


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await getCurrentUser();
await getPreferences();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //TODO
systemNavigationBarColor: Colors.black,
systemNavigationBarDividerColor: Colors.grey[900],
systemNavigationBarIconBrightness: Brightness.light
 ));
  runApp(MyApp());
}
Future getPreferences()async{
 preferences = await SharedPreferences.getInstance();
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
   SharedPreferences preferences ;
User currentUser;
String accountType;

class FakeFocusIntent extends Intent {
  const FakeFocusIntent();
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
      return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
          child: Consumer<ThemeNotifier>(
            builder: (context, ThemeNotifier notifier, child) {

    return PW.Provider(
       auth: AuthService(),
          child: MaterialApp(  shortcuts: Map<LogicalKeySet, Intent>.from(WidgetsApp.defaultShortcuts)
        ..addAll(<LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): const FakeFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowRight): const FakeFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowDown): const FakeFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowUp): const FakeFocusIntent(),
        }),
          debugShowCheckedModeBanner: false,
          title: 'Scrible',
          theme:notifier.darkTheme == true? ThemeData(
            accentColor: Colors.white,
            textSelectionColor: Color.fromRGBO(205, 205, 205, 1),
            cardColor: Color.fromRGBO(50, 50, 50, 1),
            canvasColor: Color.fromRGBO(32, 32, 32, 1),
            primaryColor: Colors.blue,
            backgroundColor: Color.fromRGBO(10, 10, 10, 1),
            textTheme: Typography.whiteMountainView,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            unselectedWidgetColor: Colors.white,
          ):ThemeData(  textSelectionColor: Color.fromRGBO(51, 51, 51, 1),
              accentColor: Colors.grey,
          
            cardColor: Color.fromRGBO(238, 238, 238, 1),
            canvasColor: Color.fromRGBO(250, 250, 250, 1),
            primaryColor: Colors.blue,
            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
            textTheme: Typography.blackMountainView,
            accentTextTheme:  Typography.blackMountainView,
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
              accentColor: Colors.grey,  textSelectionColor: Color.fromRGBO(24, 24, 24, 1),
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
                dividerColor: Colors.grey,
                textSelectionColor: Color.fromRGBO(205, 205, 205, 1),
            accentColor: Colors.white,
          accentTextTheme: Typography.whiteMountainView,//
          primaryTextTheme: Typography.whiteMountainView,//
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
                    builder: (_) => AllTopicsScreen(), settings: settings);
                break;
                case AboutScreen.routeName:
                return CupertinoPageRoute(
                    builder: (_) => AboutScreen(), settings: settings);
                break;
            }
             return CupertinoPageRoute(                                                    // TODO
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
            AllSavedPostsScreen.routeName: (ctx) => AllSavedPostsScreen(),
            SettingsScreen.routeName: (ctx) => SettingsScreen(),
            ChatInfoScreen.routeName: (ctx) => ChatInfoScreen(),
            GIFsScreen.routeName: (ctx) => GIFsScreen(),
            ProfileImageCropScreen.routeName: (ctx) => ProfileImageCropScreen(),
            SearchTagScreen.routeName: (ctx) => SearchTagScreen(),
            TagScreen.routeName: (ctx) => TagScreen(),
            CollectionPostsScreen.routeName: (ctx) => CollectionPostsScreen(),
            ExplorePostsScreen.routeName: (ctx) => ExplorePostsScreen(),

            AccountScreen.routeName: (ctx) => AccountScreen(),
            AppearanceScreen.routeName: (ctx) => AppearanceScreen(),
            CollectionsScreen.routeName: (ctx) => CollectionsScreen(),
            DraftsScreen.routeName: (ctx) => DraftsScreen(),
            PushNotificationsScreen.routeName: (ctx) => PushNotificationsScreen(),
            EmailNotificationsScreen.routeName: (ctx) =>
                EmailNotificationsScreen(),
            AutoplayScreen.routeName: (ctx) => AutoplayScreen(),
             FontScreen.routeName: (ctx) => FontScreen(),
            ContentCacheScreen.routeName: (ctx) => ContentCacheScreen(),
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
            PrivacyPolicyScreen.routeName: (ctx) => PrivacyPolicyScreen(),
                 TermsOfServiceScreen.routeName: (ctx) => TermsOfServiceScreen(),
               

                 LicenseScreen.routeName: (ctx) => LicenseScreen(),
                 PackageLicensesScreen.routeName: (ctx) => PackageLicensesScreen(),
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