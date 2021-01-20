import 'package:blue/services/auth_service.dart';
import 'package:blue/services/boxes.dart';
import 'package:hasura_connect/hasura_connect.dart';

enum Stat { upvotes, downvotes, saves, shares, comments }
enum Feedback{
  suggestion,bug
}
class Hasura {
  static String jwtToken;
  static const String url = 'https://hasura-test-project.hasura.app/v1/graphql';
  static HasuraConnect hasuraConnect = HasuraConnect(
    url,
    headers: {
      'Authorization': 'Bearer $jwtToken',
    },
  );

  static getUserId({String uid}) async {
    if (uid == null) {
      uid = AuthService().getCurrentUID();
    }

    if (jwtToken == null) return;
    String _doc = """query{
  users(where:{uid:{_eq:"$uid"}}){
    user_id
  }
}""";

    var map = await hasuraConnect.query(_doc);
    print(map);
    Boxes.currentUserBox.put('user_id',
        map['data']['users'][0]['user_id']); // check if there are no results
    return map['data']['users'][0]['user_id'];
  }

  static insertUser(String name, String email, String username) async {
    if (jwtToken == null) return;
    String uid = AuthService().getCurrentUID();
    String _doc =
        'mutation{insert_users(objects: [{name: "$name",email: "$email",username: "$username",uid:"$uid"}]) { user_id}}';
   var data = await hasuraConnect.mutation(
      _doc,
    );
    await Boxes.currentUserBox.put('id', data['data']['insert_users']['returning'][0]['user_id']);
  }

  static updateUser(
      {String name,
      String email,
      String username,
      String bio,
      String website,
      String headerUrl,
      String photoUrl,
      String avatarUrl}) async {
       int  userId = Boxes.currentUserBox.get('user_id');
      if (userId == null) {
        String uid = AuthService().getCurrentUID();
        userId = await getUserId(uid: uid);
      }
        print('updating user data');
    if (jwtToken == null) return;
    String bioModified = bio.replaceAll("\n", "\\n"); //TODO check more

    String fields = '';
    if (name != null) {
      fields = fields + 'name: "$name",';
    }
    if (email != null) {
      fields = fields + 'email: "$email",';
    }
    if (username != null) {
      fields = fields + 'username: "$username",';
    }
    if (bio != null) {
      fields = fields + 'bio: "$bioModified"';
    }
    if (website != null) {
      fields = fields + 'website: "$website",';
    }
    if (headerUrl != null) {
      fields = fields + 'header_url: "$headerUrl",';
    }
    if (headerUrl != null) {
      fields = fields + 'photo_url: "$photoUrl",';
    }
    if (avatarUrl != null) {
      fields = fields + 'avatar_url: "$avatarUrl",';
    }

    String _doc =
        'mutation{update_users_by_pk(pk_columns: {user_id: $userId}_set:{$fields}) {name}}';
    print(_doc);
    await hasuraConnect.mutation(
      _doc,
    );
  }

  static getUser({int id, bool self}) async {
    if (jwtToken == null) return;
    var userId;
    if (self == true) {
      userId = Boxes.currentUserBox.get('user_id');
      if (userId == null) {
        String uid = AuthService().getCurrentUID();
        userId = await getUserId(uid: uid);
      }
      id = userId;
    }

    String _doc = """query{
  users_by_pk(user_id:$id){
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
    return hasuraConnect.query(
      _doc,
    );
  }

  static insertPost(List contents, String title, {List<String> tags}) async {
    if (jwtToken == null) return;
    String uid = AuthService().getCurrentUID();
    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId(uid: uid);
    }
    print(contents);
    String tagsString = '';
    if (tags != null) {
      tags.forEach((t) {
        tagsString = tagsString +
            '{tag: {data: {tag: "$t"}, on_conflict: {constraint: tags_tag_key, update_columns: [tag]}}}';
      });
    }
    String _doc = tags == null
        ? """mutation insertData  {
  insert_posts_one(object: {contents: $contents, owner_id: "$userId", title: "$title", uid: "$uid", post_stats: {
          data: [
            {
             upvotes:0
            }
          ]
        }}) {
    __typename
  }
}
"""
        : """mutation {
  insert_posts_one(object: {contents: $contents, owner_id: "$userId", title: "$title", uid: "$uid", post_tags: {data: [$tagsString]}}) {
    __typename
  }
}
""";
    await hasuraConnect.mutation(_doc);
  }

  static updatePreferences(String key, dynamic value) async {
    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    try {
      String field = '$key:${value == null?null: "$value"}';
print(field);
      hasuraConnect.mutation(
          """mutation{update_preferences_by_pk(pk_columns: {user_id: $userId}_set:{$field}) {__typename}}""");
    } catch (e) {
      insertPreferences();
    }
  }

  static insertPreferences() async {
    int userId = Boxes.currentUserBox.get('id');
    if (userId == null) {
      userId = await getUserId();
    }
    String uid = AuthService().getCurrentUID();
    hasuraConnect.mutation("""mutation{
  insert_preferences_one(object:{uid:"$uid",user_id:$userId}){
    __typename
  }
}""");
  }

  static dynamic getPreferences(String key) async {
    int userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    dynamic data = await hasuraConnect.query("""query{
   preferences_by_pk(user_id:$userId){
    $key
  }
}""");
    return data['data']['preferences_by_pk'][key];
  }

  static getPosts(int limit, int offset, String orderby, {String where}) async {
    print(jwtToken);
    String param = 'limit:$limit,offset:$offset,order_by:$orderby';
    if (where != null) {
      param = param + ',where:$where';
    }
    var data = await hasuraConnect.query("""query{
  posts($param){
    contents
    created_at
    owner_id
    post_id
    title
    user{
      avatar_url
      username
    }
    post_tags{
      tag{tag}
    }
    post_stats{
      upvotes
      shares
      comments
      saves
    }

  }
}""");
    return data['data']['posts'];
  }

  static getTagPosts(
    int limit,
    int offset,
    String orderby, {
    String tag,
  }) async {
    print(jwtToken);
    String param = 'limit:$limit,offset:$offset';
    param = param + ',where:{tag:{_eq:"$tag"}}';

    var data = await hasuraConnect.query("""query{
  tags($param){
    tag_posts{
      post{
         contents
          created_at
           owner_id
             post_id
           title
          user{
           avatar_url
              username
            }
    post_tags{
      tag{tag}
    }
      }
    }
  }
}""");
    return data['data']['tags'][0]['tag_posts'];
  }

  static createTag(String _tag) async {
    print(_tag);
    await hasuraConnect.mutation("""mutation{
  insert_tags_one(object:{tag: "$_tag"}){
  __typename
  }
}""");
  }

  static searchTags(String tag) async {
    var tagsData = await hasuraConnect.query("""query{
  tags(where: {tag: {_ilike: "%$tag%"}},order_by:{post_count:desc},limit:20) {
   tag
   post_count
  }
}""");
    dynamic tagsMap = tagsData['data']['tags'];
    List tags = [];
    tagsMap.forEach((element) {
      tags.add({"tag": element['tag'], 'postCount': element['post_count']});
    });
    return tags;
  }

  static String updateStats(Stat type, String uuid, bool inc) {
    return """update_post_stats(
   where: {id: {_eq: "$uuid"}},
    _inc: {${type.toString().substring(5)}: ${inc ? 1 : -1}}
  ){
    affected_rows
  }""";
  }

  static insertPostVote(String postId, bool up) async {
    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    String string = """mutation{
  insert_${up ? "up" : "down"}votes_one(object:{
    post_id:"$postId",
    user_id:$userId
  }){
   __typename
  }
  ${updateStats(up ? Stat.upvotes : Stat.downvotes, postId, true)}
}
""";
    print(string);
    await hasuraConnect.mutation(string);
  }

  static deletePostVote(String postId, bool up) async {
    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    String string = """mutation{
 delete_${up ? "up" : "down"}votes_by_pk(
    post_id:"$postId",
    user_id:$userId
  ){
   __typename
  }
  ${updateStats(up ? Stat.upvotes : Stat.downvotes, postId, false)}
}
""";
    print(string);
    await hasuraConnect.mutation(string);
  }

  static getSearches(int limit) async {
    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    var data = await hasuraConnect.query("""query{
  searches(limit:$limit,order_by:{searched_at:desc},where:{user_id:{_eq:$userId}}){
    text
    search_id
  }
}""");
    return data['data']['searches'];
  }

  static deleteSearch(int searchId) async {
    await hasuraConnect.mutation("""mutation{
  delete_searches_by_pk(search_id:$searchId){
    __typename
  }
}""");
  }

  static insertSearch(String text) async {
    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    await hasuraConnect.mutation("""mutation{
  insert_searches_one(object:{text:"$text",user_id:$userId}){
    __typename
  }
}""");
  }

  static getSearchedPosts(String text) async {
    dynamic data = await hasuraConnect.query("""query{
  search_posts(
     
      args: {search: "$text"}){
    contents
    created_at
    owner_id
    post_id
    title
    user{
      avatar_url
      username
    }
    post_tags{
      tag{tag}
    }
    post_stats{
      upvotes
      shares
      comments
      saves
  }
}""");
    return data['data']["search_users"];
  }

  static getSearchedUsers(String text) async {
    dynamic data = await hasuraConnect.query("""query{
  search_users(
      args: {search: "$text"}){
      name
      username
      avatar_url
  }
}""");
    return data['data']["search_users"];
  }

  static getSearchedTags(String text) {}

 static insertFeedback(Feedback feedback,Map data)async{//TODO : fix user_id
 var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
   hasuraConnect.mutation("""mutation{
     insert_${feedback.toString().substring(9)}s_one(object:{brand:"${data['brand']}",${feedback == Feedback.bug?"bug":"suggestion"}:"${data['bug']}",device:"${data['device']}",manufacturer:"${data['manufacturer']}",model:"${data['model']}",platform:"${data['platform']}",product:"${data['product']}",resolution:"${data['resolution']}",user_id:$userId,version:${data['version']},version_release:"${data['version.release']}"}){
       __typename
     }
     
   }""");
  }

static getUsers()async{
  var data = await hasuraConnect.query("""query{
  users{
    avatar_url
    name
    user_id
    username
  }
}""");
return data['data']['users'];
} 

}
