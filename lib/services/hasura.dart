import 'package:blue/screens/comments_screen.dart';
import 'package:blue/screens/home.dart';
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:hive_cache_interceptor/hive_cache_interceptor.dart';
import './token_interceptor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './hasura_x.dart';

enum Report { abusive, spam, inappropriate }
enum Stat { upvotes, downvotes, saves, shares, comments }
enum Feedback { suggestion, bug }
enum UserInfo { mute, block, report }

class Hasura {
  static String jwtToken;
  static String postInfo = """  contents
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
    }""";
  static const String url = 'https://stark-development.hasura.app/v1/graphql';
  static var cacheInterceptor = HiveCacheInterceptor("hasura");
  static int postLimit = 8;
  static HasuraConnectX hasuraConnect = HasuraConnectX(url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
      interceptors: [TokenInterceptor(FirebaseAuth.instance), cacheInterceptor],
      onAuthStateChanged: AuthService().onAuthStateChanged);

  static getUserId({String uid}) async {
    uid = FirebaseAuth.instance.currentUser.uid;
    if (uid == null) {
      if (Boxes.currentUserBox != null) {
        Boxes.openCurrentUserBox();
      }
      if (Boxes.currentUserBox.get('user_id') != null) {
        return Boxes.currentUserBox.get('user_id');
      }
    }
    print(uid);

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

  // static upsertUser(String name, String email, {String username}) async {
  //   if (jwtToken == null) return;
  //   String uid = AuthService().getCurrentUID();
  //   String _doc =
  //       """mutation{insert_users(objects: [{name: "$name",email: "$email",uid:"$uid"}], on_conflict: {
  //     constraint: users_uid_key,
  //     update_columns: []
  //   }) { affected_rows}}""";
  //   var data = await hasuraConnect.mutation(
  //     _doc,
  //   );
  //   await Boxes.currentUserBox
  //       .put('id', data['data']['insert_users']['returning'][0]['user_id']);
  // }
  static getPost(int postId) async {
    var doc = await hasuraConnect.query("""query{posts_by_pk(post_id:$postId){
   contents
    created_at
    owner_id
    post_id
    title
    comment_count
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
}}""");
    return doc['data']['posts_by_pk'];
  }

  static updateUser(
      {String name,
      String email,
      String username,
      String about,
      String website,
      String headerUrl,
      String photoUrl,
      String avatarUrl,
      String token}) async {
    print('updating user');
    int userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      String uid = AuthService().getCurrentUID();
      userId = await getUserId(uid: uid);
    }
    print('updating user data');
    print(jwtToken);
    String aboutModified;
    if (jwtToken == null) {
      return;
    }
    if (about != null) {
      aboutModified = about.replaceAll("\n", "\\n");
    }
    //TODO check more

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
    if (about != null) {
      fields = fields + 'about: "$aboutModified"';
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
    if (token != null) {
      fields = fields + 'token: "$token",';
    }
    print(fields);
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
    about
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

  static getFollowedTags() async {
    int userId = await getUserId();

    String _doc = """query{
  users_by_pk(user_id:$userId){
    followed_tags{
      label
    }
  }
}""";
    var data = await hasuraConnect.query(_doc);
    return data['data']['users_by_pk']['followed_tags'];
  }

  static followTag(String tag) async {
    int userId = await getUserId();
    await hasuraConnect.mutation("""mutation{
  insert_user_followed_tags_one(object:{tag:"$tag",user_id:$userId}){
    __typename
  }
}""");
  }

  static unfollowTag(String tag) async {
    int userId = await getUserId();
    await hasuraConnect.mutation("""mutation{
  delete_user_followed_tags_by_pk(tag:"$tag", user_id:$userId){
    __typename
  }
}""");
  }

  static insertConversation(int peerId) async {
    int userId = await getUserId();
    int id1, id2;
    if (peerId > userId) {
      id1 = peerId;
      id2 = userId;
    } else {
      id2 = peerId;
      id1 = userId;
    }
    await hasuraConnect.mutation("""mutation{
  insert_conversations_one(object:{user1_id:$id1,user2_id:$id2}){
    conv_id
  }
}""");
  }

  static insertPost(List contents, String title,
      {List<String> tags, String topicName}) async {
    if (jwtToken == null) return;
    String uid = AuthService().getCurrentUID();
    var userId = await getUserId(uid: uid);
    print(contents);
    String tagsString = '';
    if (tags != null) {
      tags.forEach((t) {
        tagsString = tagsString +
            '{tag: {data: {tag: "$t"}, on_conflict: {constraint: tags_tag_key, update_columns: [tag]}}}';
      });
    }
    String topic = "";
    if (topicName != null) {
      topic = ' category:"$topicName",';
    }
    String _doc = tags == null
        ? """mutation insertData  {
  insert_posts_one(object: {contents: $contents, owner_id: $userId, title: "$title", uid: "$uid",$topic post_stats: {
          data: [
            {
             upvotes:0
            }   
          ]
        }}) {
    post_id
  }
}
"""
        : """mutation{
  insert_posts_one(object: {contents: $contents, owner_id: $userId, title: "$title", uid: "$uid",$topic post_tags: {data: [$tagsString]}}) {
    post_id
  }
}
""";
    print(_doc);

    dynamic _data = await hasuraConnect.mutation(_doc);
    print(_data);
    await hasuraConnect.mutation("""mutation{
  insert_post_stats_one(object:{post_id:${_data['data']['insert_posts_one']['post_id']},}){post_id}
}""");
  }

  static deletePost(int postId) async {
    await hasuraConnect.mutation("""mutation{
  delete_posts_by_pk(post_id:$postId){
    __typename
  }
}""");
  }

  static updatePreferences(String key, dynamic value, {bool string}) async {
    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    string = string ?? false;
    try {
      String field;
      if (!string) {
        field = '$key:${value == null ? null : "$value"}';
      } else {
        field = '$key:"${value == null ? null : "$value"}"';
      }

      await hasuraConnect.mutation(
          """mutation{update_preferences_by_pk(pk_columns: {user_id: $userId}_set:{$field}) {__typename}}""");
    } catch (e) {
      //TODO
    }
  }

  static insertPreferences(
    String uid,
  ) async {
    var userId = await getUserId(uid: uid);
    print(userId);
    print(uid);
    print('dwd');
    hasuraConnect.mutation("""mutation{
  insert_preferences_one(object:{user_id:$userId,uid:"$uid"}){
    __typename
  }
}""");
  }

  static dynamic getPreferences(String key) async {
    int userId = await getUserId();
    dynamic data = await hasuraConnect.query("""query{
   preferences_by_pk(user_id:$userId){
    $key
  }
}""");
    if (data['data']['preferences_by_pk'] == null) {
      return DateTime(2020).toString();
    }
    return data['data']['preferences_by_pk'][key];
  }

  static dynamic getAllPreferences() async {
    int userId = await getUserId();
    print('userId:$userId');
    print("""query{
   preferences_by_pk(user_id:$userId){
    email_announcements
    email_feedbacks
    hide_sensitive_content
    push_comment_replies
    push_comments
    push_direct_requests
    push_features
    push_upvotes
    push_new_followers
    push_reminders
    serif
    is_private
    track_activity
    autoplay_videos
    dark_mode
    theme
    searches_last_cleared
    set_private
    following_posts_last_seen
    mute_push_time
  }
}""");
    dynamic data = await hasuraConnect.query("""query{
   preferences_by_pk(user_id:$userId){
    email_announcements
    email_feedbacks
    hide_sensitive_content
    push_comment_replies
    push_comments
    push_direct_requests
    push_features
    push_upvotes
    push_new_followers
    push_reminders
    serif
    is_private
    track_activity
    autoplay_videos
    dark_mode
    theme
    searches_last_cleared
    set_private
    following_posts_last_seen
    mute_push_time
  }
}""");
    print(data);

    return data['data']['preferences_by_pk'];
  }

  static getPosts(int limit, int offset, String orderby, {String where}) async {
    print(jwtToken);
    String param = 'limit:$limit,offset:$offset,order_by:$orderby';
    if (where != null) {
      param = param + ',where:$where';
    }
    print(param);
    var data = await hasuraConnect.query("""query{
  posts($param){
    contents
    created_at
    owner_id
    post_id
    title
    upvoted_by_user
    comment_count
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
    print(data);
    return data['data']['posts'];
  }

  static getTagPosts(int limit, int offset, String orderby,
      {String tag}) async {
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
    upvoted_by_user
    comment_count
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

  static findTags(String tag) async {
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

  static String updateStats(Stat type, int id, bool inc) {
    //TODO : where
    return """update_post_stats(
   where: {post_id: {_eq: $id}},                 
    _inc: {${type.toString().substring(5)}: ${inc ? 1 : -1}}
  ){
    affected_rows
  }""";
  }

  static insertPostVote(int postId, bool up) async {
    var userId = await getUserId();
    String string = """mutation{
  ${updateStats(up ? Stat.upvotes : Stat.downvotes, postId, true)}
}
""";
    print(string);
    await hasuraConnect.mutation(string);
    print("""mutation{
  insert_upvotes_one(object:{post_id:$postId,user_id:$userId}){
   __typename
  }
}""");
    await hasuraConnect.mutation("""mutation{
  insert_upvotes_one(object:{post_id:$postId,user_id:$userId}){
   __typename
  }
}""");
  }

  static deletePostVote(int postId, bool up) async {
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
    var time = await PreferencesUpdate().getFuture('searches_last_cleared');
    DateTime timed =
        DateTime.parse(time).subtract(DateTime.now().timeZoneOffset);
    time = timed.toString();
    String field;
    if (time == null) {
      field = "where:{user_id:{_eq:$userId}}";
    } else {
      field =
          'where:{_and:[{user_id:{_eq:$userId}},{searched_at:{_gt:"$time"}}]}';
    }
    String doc = """query{
  searches(limit:$limit,order_by:{searched_at:desc},$field){
    text
    search_id
  }
}""";
    print(doc);
    var data = await hasuraConnect.query(doc);
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

  static searchPosts(String text) async {
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
    }}
}""");
    print(data["data"]["search_posts"]);
    return data["data"]["search_posts"];
  }

  static searchPeople(String text) async {
    dynamic data = await hasuraConnect.query("""query{
  search_users(
      args: {search: "$text"}){
      name
      username
      avatar_url
      user_id
  }
}""");
    return data['data']["search_users"];
  }

  static searchTags(String text) async {
    dynamic data = await hasuraConnect.query("""query{
  search_tags(
      args: {search: "$text"}){
    tag_id
    tag
    label}
}""");
    return data['data']["search_tags"];
  }

  static insertFeedback(Feedback feedback, Map data) async {
    //TODO : fix user_id
    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    hasuraConnect.mutation("""mutation{
     insert_${feedback.toString().substring(9)}s_one(object:{brand:"${data['brand']}",${feedback == Feedback.bug ? "bug" : "suggestion"}:"${data['bug']}",device:"${data['device']}",manufacturer:"${data['manufacturer']}",model:"${data['model']}",platform:"${data['platform']}",product:"${data['product']}",resolution:"${data['resolution']}",user_id:$userId,version:${data['version']},version_release:"${data['version.release']}"}){
       __typename
     }
     
   }""");
  }

  static getChatUsers() async {
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

  static insertMessage(int peerId, int convId, String type, String data) async {
    if (type != 'text' && type != 'image' && type != 'gif') {
      return;
    }

    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    await hasuraConnect.mutation("""mutation{
  insert_messages_one(object:{data:"$data",sender_id:$userId,conv_id:$convId,type:"$type"}){created_at}
}""");
  }

  static getConversations() async {
    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    var data = await hasuraConnect.query("""query{
  conversations(where: {_or: [{user1_id: {_eq: $userId}}, {user2_id: {_eq: $userId}}]}) {
    conv_id
    user1{
      user_id
      name
      username
      avatar_url
    }
    user2{
       user_id
      name
      username
      avatar_url
    }
  }
}
""");
    return data['data']['conversations'];
  }

  static getMessages(int convId) async {
    var data = await hasuraConnect.query("""query{
  messages(where:{conv_id:{_eq:$convId}}){
    created_at
    data
    msg_id
    sender_id
    type
    deleted_by_sender
  }
}
""");
    return data['data']['messages'];
  }

  static subscribeMessages(int convId, DateTime lastTime) {
//     has.Snapshot snap = has.HasuraConnect(url,
//             token: (isError) async {
//               return jwtToken;
//             },
//             localStorageDelegate: () => has.LocalStorageHive('subscriptions'))
//         .subscription("""subscription{
//   messages(where:{_and:[{conv_id:{_eq:$convId}},{created_at:{_gt:$lastTime}}]},){
//     created_at
//     data
//     msg_id
//     sender_id
//     recipient_id
//     type
//   }
// }""");
    // snap.listen((data) {
    //   print('snap:');
    //   print(data);
    // }).onError((err) {
    //   print(err);
    // });
  }

  static updateCommentVote(bool up, int postId, String time) async {
    await hasuraConnect.mutation("""mutation{
  update_comments_by_pk(pk_columns:{post_id:$postId,created_at:"$time"},
  _inc:{upvotes:${up ? 1 : -1}}
  ){
    upvotes
  }
}""");
  }

  static updateCommentReplieyVote(bool up, int replyId, String time) async {
    await hasuraConnect.mutation("""mutation{
  update_comment_replies_by_pk(pk_columns:{reply_id:$replyId},
  _inc:{upvotes:${up ? 1 : -1}}
  ){
    upvotes
  }
}""");
  }

  static getActivityFeed({DateTime lastTime}) async {
    int userId = await getUserId();
    String where = '{user_id:{_eq:$userId}}';
    if (lastTime != null) {
      where = "{_and:[{user_id:{_eq:$userId}},{created_at:{_gt:$lastTime}}]}";
    }
    print("""query{
  activity_feed(where:$where,order_by:{created_at:desc}){
    created_at
    data
  }
}""");
    var data = await hasuraConnect.query("""query{
  activity_feed(where:$where,order_by:{created_at:desc}){
    created_at
    data
  }
}
""");
    return data['data']['activity_feed'];
  }

  static muteUser(int peerId) async {
    int id = await getUserId();

    hasuraConnect.mutation("""mutation{
  insert_user_mutes_one(object:{user_id:$id,muted_user_id:$peerId}){user_id
  }
}""");
  }

  static reportUser(int peerId, Report type) async {
    int id = await getUserId();

    hasuraConnect.mutation("""mutation{
  insert_user_reports_one(object:{user_id:$id,reported_user_id:$peerId,${type.toString().substring(7)}:true},on_conflict:{
    constraint:user_reports_pkey,
    update_columns:[${type.toString().substring(7)}]
  }){user_id
  }
}
""");
  }

  static blockUser(int peerId) async {
    int id = await getUserId();

    hasuraConnect.mutation("""mutation{
  insert_user_blocks_one(object:{user_id:$id,blocked_user_id:$peerId}){user_id
  }
}""");
  }

  static Future<bool> checkUserInfo(int id, UserInfo info) async {
    var userId = await getUserId();
    var c = await hasuraConnect.query("""query{
  user_${info.toString().substring(9)}s_by_pk(${info.toString().substring(9)}${info == UserInfo.mute ? 'd' : 'ed'}_user_id:$id,user_id:$userId){
    ${info.toString().substring(9)}${info == UserInfo.mute ? 'd' : 'ed'}_user_id
  }
}""");
    print(c);
    if (c['data']['user_${info.toString().substring(9)}s_by_pk'] == null) {
      return false;
    }
    return true;
  }

  static Future<Map> checkUserAllInfo(int id) async {
    var userId = await getUserId();
    Map data = {};
    try {
      var c = await hasuraConnect.query("""query{
  user_mutes_by_pk(muted_user_id:$id,user_id:$userId){
    muted_user_id
  }
  user_blocks_by_pk(blocked_user_id:$id,user_id:$userId){
    blocked_user_id
  }
}""");

      data['muted'] = c['data']['user_mutes_by_pk'] != null;
      data['blocked'] = c['data']['user_blocks_by_pk'] != null;
      return data;
    } catch (e) {
      data['muted'] = false;
      data['blocked'] = false;
      return data;
    }
  }

  static deleteUserInfo(int peer, UserInfo info) async {
    int id = await getUserId();
    print("""mutation{
  delete_user_${info.toString().substring(9)}s_by_pk(user_id:$id,muted_user_id:$peer){
__typename
  }
}""");
    await hasuraConnect.mutation("""mutation{
  delete_user_${info.toString().substring(9)}s_by_pk(user_id:$id,${info.toString().substring(9)}${info == UserInfo.mute ? 'd' : 'ed'}_user_id:$peer){
__typename
  }
}""");
  }

  static insertComment(dynamic postId, String comment, int ownerId) async {
    int userId = await getUserId();
    String token = await getToken(ownerId);
    dynamic data = await hasuraConnect.mutation("""mutation{
  insert_comments_one(object:{data:"$comment",post_id:$postId,user_id:$userId, payload:{token:"$token"}}){
    comment_id
    created_at
    data
    user_id
    post_id
    reply_count
    user_vote
     user{
      avatar_url
      username
    }
    upvotes
    downvotes
    
    comment_replies{
      user{
        avatar_url
        username
      }
      user_vote
      comment_id
      created_at
      reply_id
      user_id
      upvotes
      downvotes
      data
    }
  }
}
""");
    String doc1 =
        """mutation{update_posts_by_pk(pk_columns:{post_id:$postId,},_inc:{comment_count:1}){
    __typename
  }
  }""";
    print(doc1);
    await hasuraConnect.mutation(doc1);
    return data['data']['insert_comments_one'];
  }

  static insertCommentReply(dynamic postId, int commentId, String text,
      String createdAt, int commenterId) async {
    int userId = await getUserId();
    String token = await getToken(commenterId);
    String doc = """mutation{
  insert_comment_replies_one(object:{comment_id:$commentId,user_id:$userId,data:"$text",  payload:{token:"$token"}}){                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
    user{
        avatar_url
        username
      }
      user_vote
      comment_id
      created_at
      reply_id
      user_id
      upvotes
      downvotes
      data
  }
}

  """;
    String doc1 =
        """mutation{update_comments_by_pk(pk_columns:{post_id:$postId,created_at:"$createdAt",},_inc:{reply_count:1}){
    __typename
  }
  }""";
    print(doc1);
    var data = await hasuraConnect.mutation(doc);
    await hasuraConnect.mutation(doc1);
    return data['data']['insert_comment_replies_one'];
  }

  static insertCommentReport(int id, bool isReply) async {
    int userId = await getUserId();
    await hasuraConnect.mutation("""mutation{
  insert_comment_reports_one(object:{comment_id:$id,user_id:$userId,is_reply:$isReply}){
    
    user_id
  }
}""");
    return;
  }

  static getComments(
      dynamic postId, int offset, int limit, CommentSort sort) async {
    String sortString;
    if (sort == CommentSort.best) {
      sortString = "upvotes:desc";
    } else if (sort == CommentSort.top) {
      sortString = "upvotes:desc";
    } else if (sort == CommentSort.oldest) {
      sortString = "created_at:asc";
    } else if (sort == CommentSort.newest) {
      sortString = "created_at:desc";
    }
    dynamic comments = await hasuraConnect.query("""query{
  comments(where:{post_id:{_eq:$postId}},limit:$limit,offset:$offset,order_by:{$sortString}){
      comment_id
    created_at
    data
    user_id
    post_id
    reply_count
    user_vote
     user{
      avatar_url
      username
    }
    upvotes
    downvotes

    comment_replies{
      user{
        avatar_url
        username
      }
      user_vote
      comment_id
      created_at
      reply_id
      user_id
      upvotes
      downvotes
      data
    }
   
  }
  
}""");
    return comments['data']['comments'];
  }

  static updateSavedPost(String name, int postId) async {
    int userId = await getUserId();
    await hasuraConnect.mutation("""mutation{
  update_saved_posts_by_pk(pk_columns:{post_id:$postId,user_id:$userId},_set:{collection:"$name"}){
   collection
  }
}

""");
  }

  static insertCollection(String name) async {
    int userId = await getUserId();
    try {
      await hasuraConnect.mutation("""mutation{
  insert_collections_one(object:{collection:"$name",user_id:$userId}){
    __typename
    collection
  }
}""");
    } catch (e) {}
  }

  static getCollections() async {
    dynamic userId = await getUserId();

    dynamic data = await hasuraConnect.query("""query{
  collections(where:{user_id:{_eq:$userId}}){
    collection
  }
}""");
    return data['data']['collections'];
  }

  static getSavedPosts(int offset) async {
    dynamic userId = await getUserId();
    dynamic data = await hasuraConnect.query("""query{
  saved_posts(limit:$postLimit,where:{user_id:{_eq:$userId}},offset:$offset,order_by:{post:{created_at:desc}}){
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
    post_stats{
      upvotes
      shares
      comments
      saves
    }
    }
    
  }
}""");
    return data['data']['saved_posts'];
  }

  static getCollectionPosts(String name, int offset) async {
    dynamic userId = await getUserId();
    dynamic data = await hasuraConnect.query("""query{
  saved_posts(limit:$postLimit,where:{_and:[{user_id:{_eq:$userId}},{collection:{_eq:"$name"}}]},offset:$offset,order_by:{post:{created_at:desc}}){
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
    post_stats{
      upvotes
      shares
      comments
      saves
    }
    }
    
  }

}

""");
    return data['data']['saved_posts'];
  }

  static insertSavedPost(int postId) async {
    int userId = await getUserId();
    await hasuraConnect.mutation("""mutation{
  insert_saved_posts_one(object:{post_id:$postId,user_id:$userId}){
    __typename
  }
}
""");
  }

  static deleteSavedPost(int postId) async {
    int userId = await getUserId();
    await hasuraConnect.mutation("""mutation{
  delete_saved_posts_by_pk(post_id:$postId,user_id:$userId){
   __typename
  }
}
""");
  }

  static insertFollow(int peerId) async {
    int userId = await getUserId();
    await hasuraConnect.mutation("""mutation{
  insert_follows_one(object:{follower_id:$userId,following_id:$peerId}){
    __typename
  }
}""");
  }

  static deleteFollow(int peerId) async {
    int userId = await getUserId();
    await hasuraConnect.mutation("""mutation{
  delete_follows_by_pk(follower_id:$userId,following_id:$peerId){
    __typename
  }
}""");
  }

  static getFollowingPosts(bool last) async {
    int userId = await getUserId();
    String field = '';
    if (last) {
      dynamic t = PreferencesUpdate().getString('following_posts_last_seen');
      if (t == null) {
        dynamic ti = await hasuraConnect.query("""query{
  preferences_by_pk(user_id:$userId){
    following_posts_last_seen
  }
}
""");
        t = ti['data']['preferences_by_pk']['following_posts_last_seen'];

        if (t == null) {
          t = DateTime(2021);
        }
      }
      DateTime time = DateTime.parse(t);
      field = 'where:{created_at:{_gt:"$time"}}';
      t = DateTime.now().toString();

      await PreferencesUpdate()
          .updateString('following_posts_last_seen', t, upload: true);
    } else {
      int f = 40; //TODO following no.
      double days = 2000 / f;
      int d = days
          .ceil(); //TODO Check and also do multiple times when not enough(if needed)
      int y = (d / 365).floor();
      d = d - y * 365;
      int m = (d / 30).floor();
      d = d - m * 30;
      DateTime now = DateTime.now();

      DateTime lastTime = DateTime(
          now.year - y, now.month - m, now.day - d, now.hour, now.minute);

      field = 'where:{created_at:{_gt:"$lastTime"}}';
    }

    dynamic data = await hasuraConnect.query("""query{
  follows(where:{follower_id:{_eq:$userId}}){
    following{
      posts($field){
        $postInfo
      }
    }
  }
}""");

    dynamic userPosts = data['data']['follows'];
    List posts = [];
    userPosts.forEach((user) {
      posts.add(user['following']['posts']);
    });
    List p = [];
    posts.forEach((ps) {
      ps.forEach((pss) {
        p.add(pss);
      });
    });
    p.sort((a, b) {
      return DateTime.parse(a['created_at'])
          .compareTo(DateTime.parse(b['created_at']));
    });
    return p;
  }

//--------------------miscellaneous----------------------
  static checkUsername(String username) async {
    dynamic data = await HasuraConnect(
      url,
    ).query("""query{
  users(where:{username:{_eq:"$username"}}){
   username
  }
}
    """);
    print(data['data']['users'].length);
    if (data['data']['users'].length != 0) {
      return true;
    }
    return false;
  }

  static userExists(String uid) async {
    dynamic data = await HasuraConnect(
      url,
    ).query("""query{
  users(where:{uid:{_eq:"$uid"}}){
   uid
  }
}
    """);
    print(data['data']['users'].length);
    if (data['data']['users'].length != 0) {
      return true;
    }
    return false;
  }

  static createUser(String email, String name, String username, int userId,
      String uid) async {
    await HasuraConnect(
      url,
    ).mutation("""mutation{
  insert_users_one(object:{email:"$email",name:"$name",username:"$username",user_id: $userId, uid: "$uid"}){
 __typename
  }
}
    """);
  }

  static getToken(int userId) async {
    dynamic doc = await hasuraConnect.query("""query{
  users_by_pk(user_id:$userId){
    token
  }
}""");
    return doc['data']['users_by_pk']['token'];
  }

  static getFollowingIds() async {
    int userId = await getUserId();
    dynamic doc = await hasuraConnect
        .query("""query{follows(where:{follower_id:{_eq:$userId}}){
  following_id
}}""");
    return doc['data']['follows'];
  }

  static deleteCommentVote(bool reply, int id, bool upinc, bool downinc,
      {String time, int postId, int replyId}) async {
    dynamic userId = await getUserId();
    String cr = reply ? "comment_reply" : "comment";
    String r = reply ? "reply" : "comment";
    print("""mutation{
  delete_${cr}_votes_by_pk(${r}_id: $id,user_id:$userId){__typename}
}""");
    await hasuraConnect.mutation("""mutation{
  delete_${cr}_votes_by_pk(${r}_id: $id,user_id:$userId){__typename}
}""");
    String pk =
        !reply ? 'created_at:"$time",post_id:$postId' : 'reply_id:$replyId';
    await hasuraConnect.mutation("""mutation{
  update_comments_by_pk(pk_columns:{$pk},_inc:{upvotes:${upinc == null ? 0 : upinc ? 1 : -1},downvotes:${downinc == null ? 0 : downinc ? 1 : -1},},){
    __typename
    
  }
}""");
  }

  static insertCommentVote(
      bool reply, int id, bool vote, bool upinc, bool downinc,
      {String time, int postId, int replyId}) async {
    dynamic userId = await getUserId();
    String cr = reply ? "comment_reply" : "comment";
    String crs = reply ? "comment_replies" : "comments";
    String r = reply ? "reply" : "comment";

    await hasuraConnect.mutation("""
    mutation{
  insert_${cr}_votes_one(object:{user_id:$userId,${r}_id:$id, upvote: $vote, },on_conflict: {
constraint: ${cr}_${reply ? '' : 'up'}votes_pkey,
update_columns: [upvote]
}){
    __typename
  }
}
    """);

    String pk =
        !reply ? 'created_at:"$time",post_id:$postId' : 'reply_id:$replyId';
    String doc = """mutation{
  update_${crs}_by_pk(pk_columns:{$pk},_inc:{upvotes:${upinc == null ? 0 : upinc ? 1 : -1},downvotes:${downinc == null ? 0 : downinc ? 1 : -1}},){
    __typename
    
  }
}""";
    print(doc);
    await hasuraConnect.mutation(doc);
  }
}
