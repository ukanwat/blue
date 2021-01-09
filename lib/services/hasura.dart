import 'package:blue/services/auth_service.dart';
import 'package:blue/services/boxes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hasura_connect/hasura_connect.dart';



class Hasura{
  static String jwtToken;
 static const String url = 'https://hasura-test-project.hasura.app/v1/graphql';
static HasuraConnect hasuraConnect = HasuraConnect(url,headers: { 'Authorization': 'Bearer $jwtToken',},);

static getUserId({String uid})async {
  if(uid ==  null){
   uid =  AuthService().getCurrentUID();
  }

   if(jwtToken == null)
  return;
  String _doc = """query{
  users(where:{uid:{_eq:"$uid"}}){
    user_id
  }
}""";

var map = await hasuraConnect.query(_doc);
Boxes.currentUserBox.put('user_id', map['data']['users'][0]['user_id']);   // check if there are no results
return  map['data']['users'][0]['user_id'];
}
static insertUser(String name,String email, String username)async{
  if(jwtToken == null)
  return;
  String uid =  AuthService().getCurrentUID();
  String _doc = 'mutation{insert_users(objects: [{name: "$name",email: "$email",username: "$username",uid:"$uid"}]) { affected_rows}}'; 
 await hasuraConnect.mutation(_doc,);
  var userId = getUserId(uid:uid);
  await Boxes.currentUserBox.put('user_id', userId);
}
static updateUser({String name,String email, String username,String bio, String website, String headerUrl, String photoUrl,String avatarUrl })async{
  if(jwtToken == null)
  return;
  String bioModified =bio.replaceAll("\n", "\\n");//TODO check more
  
  String fields = '';
  if(name != null){
    fields = fields + 'name: "$name",';
  }
    if(email != null){
    fields = fields + 'email: "$email",';
  }  if(username != null){
    fields = fields + 'username: "$username",';
  }  if(bio != null){
    fields = fields + 'bio: "$bioModified"';
  }  if(website != null){
    fields = fields + 'website: "$website",';
  }  if(headerUrl != null){
    fields = fields + 'header_url: "$headerUrl",';
  } if(headerUrl != null){
    fields = fields + 'photo_url: "$photoUrl",';
  } if(avatarUrl != null){
    fields = fields + 'avatar_url: "$avatarUrl",';
  } 

  String _doc = 'mutation{update_users_by_pk(pk_columns: {user_id: 6}_set:{$fields}) {name}}'; 
  print(_doc);
 await hasuraConnect.mutation(_doc,);
}
static getUser()async{
  if(jwtToken == null)
  return;

  var userId =  Boxes.currentUserBox.get('user_id');
   if(userId == null){
      String uid =  AuthService().getCurrentUID();
    userId =  await getUserId(uid:uid);
    }
  print('$userId ssss');
  String _doc = """query{
  users_by_pk(user_id:$userId){
    avatar_url
    bio
    email
    header_url
    joined
    name
    photo_url
    uid
    user_id
    username
    website
  }
}"""; 
 return hasuraConnect.query(_doc,);
}
static insertPost(Map contents,String title)async{
 if(jwtToken == null)
  return;
  String uid =  AuthService().getCurrentUID();
    var userId =  Boxes.currentUserBox.get('user_id');
    if(userId == null){
    userId =  await getUserId(uid:uid);
    }
String _doc = """mutation{
  insert_posts_one(object:{contents:$contents,owner_id:"$userId",title:"$title",uid:"$uid"}){
    __typename
  }
}""";
await hasuraConnect.mutation(_doc);
}
static updatePreferences(String key,dynamic value)async{
String userId =Boxes.currentUserBox.get('user_id');
if(userId == null){
 userId = await getUserId();
}
  try{
   String  field = '$key: "$value"';
    hasuraConnect.mutation("""mutation{update_preferences_by_pk(pk_columns: {user_id: $userId}_set:{$field}) {__typename}}""");
  }catch(e){
    insertPreferences();
  }

}
static insertPreferences()async{
  String userId =Boxes.currentUserBox.get('user_id');
if(userId == null){
 userId = await getUserId();
}
    String uid =  AuthService().getCurrentUID();
  hasuraConnect.mutation("""mutation{
  insert_preferences_one(object:{uid:"$uid",user_id:$userId}){
    __typename
  }
}""");
}
}