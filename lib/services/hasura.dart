// Flutter imports:
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hasura_connect/hasura_connect.dart';

// Project imports:
import 'package:blue/screens/comments_screen.dart';
import 'package:blue/services/auth_service.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/progress.dart';
import './hasura_x.dart';
import './token_interceptor.dart';

// import 'package:hive_cache_interceptor/hive_cache_interceptor.dart';

enum Report { abusive, spam, inappropriate }
enum Stat {
  upvote_count,
  downvote_count,
  save_count,
  share_count,
  comment_count
}
enum Feedback { suggestion, bug }
enum UserInfo { mute, block, report }

class Hasura {
  static String jwtToken;
  static String postInfo = """  contents
    created_at
    owner_id
    post_id
    title
    subtitle
    user{
      avatar_url
      username
    }
    post_tags{
      tg{tag}
    }
       upvote_count
        downvote_count
      share_count
      comment_count
      save_count
      """;
  static const String url = 'https://app.stark.social/v1/graphql';
  // static var cacheInterceptor = HiveCacheInterceptor("hasura");
  static int postLimit = 8;
  static HasuraConnectX hasuraConnect = HasuraConnectX(
    url,
    headers: {
      'Authorization': 'Bearer $jwtToken',
    },
    interceptors: [
      TokenInterceptor(FirebaseAuth.instance),
    ],
    onAuthStateChanged: AuthService().onAuthStateChanged,
  );

  static getUserId({String uid}) async {
    uid = FirebaseAuth.instance.currentUser.uid;
    if (uid == null) {
      await Boxes.openCurrentUserBox();

      if (Boxes.currentUserBox.get('user_id') != null) {
        return Boxes.currentUserBox.get('user_id');
      }
    }

    String _doc = """query{
  users(where:{uid:{_eq:"$uid"}}){
    user_id
  }
 }""";

    var map = await hasuraConnect.query(_doc);
    await Boxes.openCurrentUserBox();
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
  static getPost(int postId, {bool link}) async {
    print("""contents
    created_at
    owner_id
    post_id
    title
    subtitle
    comment_count
    user{
      avatar_url
      username
    }
    actions_by_user{
      not_interested
      up
      time
    }
    post_tags{
      tg{tag}
    }
      upvote_count
      share_count
      comment_count
      save_count
         downvote_count""");
    var doc = await hasuraConnect.query("""query{posts_by_pk(post_id:$postId){
 contents
    created_at
    owner_id
    post_id
    title
    subtitle
    comment_count
    user{
      avatar_url
      username
    }
    actions_by_user{
      not_interested
      up
      time
    }
    post_tags{
      tg{tag}
    }
      upvote_count
      share_count
      comment_count
      save_count
         downvote_count
}}""");
    print(doc);
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
      bool deleteToken,
      bool profileComplete,
      String token,
      bool reviewed,
      String dob,
      String location,
      String place,
      String gender,
      Map social}) async {
    int userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      String uid = AuthService().getCurrentUID();
      userId = await getUserId(uid: uid);
    }
    String aboutModified;
    int i = 0;
    while (jwtToken == null) {
      i++;
      await Future.delayed(Duration(seconds: 1));
      if (i == 60) {
        return;
      }
    }
    if (about != null) {
      aboutModified = about
          .replaceAll("\n", "\\n")
          .replaceAll('\'', '\\\'')
          .replaceAll('\"', '\\\"');
    }
    //TODO check more

    String fields = '';
    if (name != null) {
      fields = fields + 'name: "$name",';
    }
    if (gender != null) {
      fields = fields + 'gender: "$gender",';
    }
    if (email != null) {
      fields = fields + 'email: "$email",';
    }
    if (social != null) {
      fields = fields + 'social: $social,';
    }
    if (location != null) {
      fields = fields + 'location: "$location",';
    }
    if (place != null) {
      fields = fields + 'place: "$place",';
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
    if (photoUrl != null) {
      fields = fields + 'photo_url: "$photoUrl",';
    }
    if (dob != null) {
      fields = fields + 'dob: "$dob",';
    }
    if (profileComplete != null) {
      fields = fields + 'profile_complete: $profileComplete,';
    }
    if (reviewed != null) {
      fields = fields + 'reviewed: $reviewed,';
    }
    if (avatarUrl != null) {
      fields = fields + 'avatar_url: "$avatarUrl",';
    }
    if (token != null) {
      fields = fields + 'token: "$token",';
    }

    if (deleteToken == true) {
      fields = fields + 'token: "_",';
    }
    String _doc =
        'mutation{update_users_by_pk(pk_columns: {user_id: $userId}_set:{$fields}) {name}}';
    await hasuraConnect.mutation(
      _doc,
    );
  }

  static getUser({int id, bool self}) async {
    if (jwtToken == null) return;
    var userId;
    String extra = '';
    if (self == true) {
      userId = Boxes.currentUserBox.get('user_id');
      if (userId == null) {
        String uid = AuthService().getCurrentUID();
        userId = await getUserId(uid: uid);
      }
      id = userId;
      extra = 'profile_complete';
    }

    String _doc = """query{
  users_by_pk(user_id:$id){
    avatar_url
    reviewed
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
    follower_count
    following_count
    social
    dob
    location
    place
    gender
    $extra
  }
}""";
    return hasuraConnect.query(
      _doc,
    );
  }

  static getUserEmail(String uid) async {
    String _doc = """query{
  users(where:{uid:{_eq:"$uid"}}){
    email
  }
}
""";
    dynamic data = await hasuraConnect.query(
      _doc,
    );
    if (data['data']['users'].length == 0) {
      return null;
    }
    return data['data']['users'][0]['email'];
  }

  static getFollowedTags() async {
    int userId = await getUserId();
    String _doc = """query{
  user_followed_tags(where:{user_id:{_eq:$userId}}){
    tag{
      tag
      label
      tag_id
      image_url
      post_count
      follower_count
    }
  }
}
""";
    var data = await hasuraConnect.query(_doc);
    return data['data']['user_followed_tags'];
  }

  static followTag(int tagId) async {
    int userId = await getUserId();
    await hasuraConnect.mutation("""mutation{
  insert_user_followed_tags_one(object:{tag_id:$tagId,user_id:$userId}){
    __typename
  }
}""");
  }

  static unfollowTag(int tagId) async {
    int userId = await getUserId();
    await hasuraConnect.mutation("""mutation{
  delete_user_followed_tags_by_pk(tag_id:$tagId, user_id:$userId){
    __typename
  }
}""");
  }

  static seenConversation(int peerId) async {
    int userId = await getUserId();
    String text;
    int id1, id2;
    if (peerId > userId) {
      text = 'user2_seen';
      id1 = peerId;
      id2 = userId;
    } else {
      text = 'user1_seen';
      id2 = peerId;
      id1 = userId;
    }
    String doc = """mutation {
  update_conversations_by_pk(pk_columns: {user1_id: $id1, user2_id: $id2}, _set: {$text: null}) {
    __typename
  }
}""";
    await hasuraConnect.mutation(doc);
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
    // user${id1 == userId ? '1' : '2'}_removed: true},on_conflict:{constraint:conversations_pkey,update_columns:[user${id1 == userId ? '1' : '2'}_removed]
    String doc = """mutation{
  insert_conversations_one(object:{user1_id:$id1,user2_id:$id2, }){
    conv_id
  }
}""";

    dynamic data = await hasuraConnect.mutation(doc);
    return data['data']["insert_conversations_one"]['conv_id'];
  }

  static hideConversation(int peerId, bool archived) async {
    int userId = await getUserId();
    int id1, id2;
    if (peerId > userId) {
      id1 = peerId;
      id2 = userId;
    } else {
      id2 = peerId;
      id1 = userId;
    }
    await hasuraConnect.mutation("""mutation {
  update_conversations_by_pk(pk_columns: {user1_id: $id1, user2_id: $id2}, _set: {user${id1 == userId ? '1' : '2'}_removed: ${archived ? false : true}}) {
    __typename
  }
}
""");
  }

  static deleteConversation(
    int peerId,
  ) async {
    int userId = await getUserId();
    int id1, id2;
    if (peerId > userId) {
      id1 = peerId;
      id2 = userId;
    } else {
      id2 = peerId;
      id1 = userId;
    }

    await hasuraConnect.mutation("""mutation {
  update_conversations_by_pk(pk_columns: {user1_id: $id1, user2_id: $id2}, _set: {user${id1 == userId ? '1' : '2'}_deleted_at: "${DateTime.now().toUtc().toString()}"}) {
    __typename
  }
}
""");
  }

  static insertPost(List contents, String title,
      {Map<int, String> tags,
      String topicName,
      String thumbUrl,
      String customUserId,
      bool explicit,
      String subtitle}) async {
    if (jwtToken == null) return;
    var userId = await getUserId();

    String subtitleText = subtitle == '' ? '' : 'subtitle:$subtitle,';
    if (!kReleaseMode) {
      if (customUserId != null && customUserId != '') {
        try {
          userId = int.parse(customUserId);
        } catch (e) {}
      }
    }
    String tagsString = '';
    if (tags != null) {
      tags.forEach((key, value) {
        tagsString =
            tagsString + '{tag: "${value.trim().toLowerCase()}", tag_id:$key},';
      });
    }
    String thumb = thumbUrl != null ? 'thumbnail: "$thumbUrl",' : '';
    String topic = "";
    if (topicName != null) {
      topic = ' category:"$topicName",';
    }
    title = title.replaceAll('\"', '\\\"');
    String _doc = tags == null
        ? """mutation insertData(\$content: jsonb!)  {
  insert_posts_one(object: {contents: \$content,explicit:$explicit, owner_id: $userId,$subtitleText title: "$title", $topic $thumb}
        ) {
    post_id
  }
}
"""
        : """mutation insertData(\$content: jsonb!)  {
  insert_posts_one(object: {contents: \$content,explicit:$explicit,  owner_id: $userId,$subtitleText title: "$title", $topic post_tags: {data: [$tagsString]}, $thumb}) {
    post_id
  }
}
""";
    print(_doc);
    dynamic _data = await hasuraConnect
        .mutation(_doc, variables: {"content": json.encode(contents)});
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
      return null;
    }
    return data['data']['preferences_by_pk'][key];
  }

  static dynamic getAllPreferences() async {
    int userId = await getUserId();

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
    push_notif_agree
    deactivation_time
    tabs
  }
}""");

    return data['data']['preferences_by_pk'];
  }

  static getPosts(int limit, int offset, String orderby, {String where}) async {
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
    subtitle
    thumbnail
    actions_by_user{
      not_interested
      up
      time
    }
    comment_count
    user{
      avatar_url
      username
    }
    post_tags{
      tg{tag}
    }
      upvote_count
      share_count
      comment_count
      save_count
         downvote_count

  }
}""");
    return data['data']['posts'];
  }

  static getTagPosts(int limit, int offset, String orderby,
      {String tag}) async {
    String param = 'limit:$limit,offset:$offset,order_by:$orderby';
    if (tag != null) {
      param = param + ',where:{post_tags:{tag:{_eq:"$tag"}}}';
    }

    var data = await hasuraConnect.query("""query{
 
      posts($param){
         contents
    created_at
    owner_id
    post_id
    title
    subtitle
    actions_by_user{
      not_interested
      up
      time
    }
    comment_count
    user{
      avatar_url
      username
    }
    thumbnail
    post_tags{
      tg{tag}
    }
      upvote_count
      share_count
      comment_count
      save_count
         downvote_count
      }
   
}""");

    return data['data']['posts'];
  }

  static createTag(String _tag) async {
    dynamic doc = await hasuraConnect.mutation("""mutation{
  insert_tags_one(object:{label: "$_tag"}){
  tag_id
  }
}""");

    return doc['data']['insert_tags_one']['tag_id'];
  }

  static getTag(String tag) async {
    dynamic doc = await hasuraConnect.query("""query{
  tags(where:{tag:{_eq:"$tag"}}){
    tag_id
    tag
    image_url
    label
    follower_count
    post_count
  }
}""");
    return doc['data']['tags'][0];
  }

  static findTags(String tag) async {
    var tagsData = await hasuraConnect.query("""query{
  tags(where: {tag: {_ilike: "%$tag%"}},order_by:{post_count:desc},limit:20) {
   tag
   tag_id
   label
   post_count
  }
}""");
    dynamic tagsMap = tagsData['data']['tags'];
    List tags = [];
    tagsMap.forEach((element) {
      tags.add({
        "tag": element['tag'],
        'postCount': element['post_count'],
        'tag_id': element['tag_id'],
        'label': element['label'],
      });
    });
    return tags;
  }

  static insertPostAction(int postId, String param) async {
    var userId = await getUserId();
    String doc = """mutation{
  insert_post_actions_one(object:{post_id:$postId,user_id:$userId,$param}){
   __typename
  }
}""";
    print(doc);
    await hasuraConnect.mutation(doc);
  }

  static updatePostAction(int postId, String param) async {
    var userId = await getUserId();
    String doc = """mutation{
  update_post_actions_by_pk(pk_columns:{post_id:$postId,user_id:$userId},_set:{$param}){
   __typename
  }
}""";
    await hasuraConnect.mutation(doc);
  }

  static getSearches(int limit) async {
    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    String t = await PreferencesUpdate().getFuture('searches_last_cleared');
    if (t == null) {
      t = DateTime(2020).toString();
    }
    var time = DateTime.parse(t);
    if (time == null) {
      time = DateTime(2020);
      PreferencesUpdate()
          .uploadValue('searches_last_cleared', time.toString(), true);
    }
    DateTime timed = time.subtract(DateTime.now().timeZoneOffset);
    time = timed;
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
    subtitle
     actions_by_user{
      not_interested
      up
      time
    }
    user{
      avatar_url
      username
    }
    post_tags{
      tg{tag}
    }
       upvote_count
      share_count
      comment_count
      save_count
         downvote_count
    }
}""");
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
    post_count
    follower_count
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

  static insertMessage(int peerId, int convId, String type, String data,
      BuildContext context) async {
    if (type != 'text' && type != 'image' && type != 'gif') {
      return;
    }
    var userId = Boxes.currentUserBox.get('user_id');
    if (userId == null) {
      userId = await getUserId();
    }
    if (data != null) {
      data = data
          .replaceAll("\n", "\\n")
          .replaceAll('\'', '\\\'')
          .replaceAll('\"', '\\\"');
    }
    String doc = """mutation{
  insert_messages_one(object:{data:"$data",sender_id:$userId,conv_id:$convId,type:"$type",sender_name: "${Boxes.currentUserBox.get("name")}" }){created_at}
}""";
    print(doc);
    await hasuraConnect.mutation(doc);
  }

  static getConversations(
    bool archived,
  ) async {
    int userId = await getUserId();

    var data = await hasuraConnect.query("""query{
  conversations(where: {_or: [{_and:[{user1_id: {_eq: $userId}},{user1_removed:{_eq:$archived}}]}, {_and:[{user2_id: {_eq: $userId}},{user2_removed:{_eq:$archived}}]}]}) {
    conv_id
    user1_seen
    user2_seen
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

  static getConvId(int peerId) async {
    int userId = await getUserId();
    int user1, user2;
    if (userId > peerId) {
      user1 = userId;
      user2 = peerId;
    } else {
      user2 = userId;
      user1 = peerId;
    }

    dynamic doc = await hasuraConnect.query("""query{
  conversations(where:{_and:[{user1_id:{_eq:$user1}},{user2_id:{_eq:$user2}}]}){
    conv_id
  }
}""");
    if (doc['data']['conversations'].length == 0) {
      return null;
    }
    return doc['data']['conversations'][0]['conv_id'];
  }

  static getConvDeletedAt(int peerId) async {
    int userId = await getUserId();
    int user1, user2;
    if (userId > peerId) {
      user1 = userId;
      user2 = peerId;
    } else {
      user2 = userId;
      user1 = peerId;
    }

    dynamic doc = await hasuraConnect.query("""query{
  conversations_by_pk(user1_id:$user1,user2_id:$user2){
    user${userId == user1 ? '1' : '2'}_deleted_at
  }
}""");

    return DateTime.parse(doc['data']['conversations_by_pk']
            ['user${userId == user1 ? '1' : '2'}_deleted_at'] ??
        '2020-07-31 22:56:08.031553');
  }

  static getMessages(int convId, {DateTime time}) async {
    if (time == null) {
      time = DateTime(2020);
    }
    String doc = """query{
  messages(where:{_and:[{conv_id: {_eq: ${convId}}},{created_at:{_gt:"${time.toString()}"}}],}, limit:100, ) {
    created_at
    data
    msg_id
    sender_id
    type
    deleted_by_sender
  }
}


""";
    print(doc);
    var data = await hasuraConnect.query(doc);
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
    // }).onError((err) {
    // });
  }

  static getNotifications({int offset, int limit}) async {
    int userId = await getUserId();

    var data = await hasuraConnect.query("""query{
  notifications(where:{_and:[{user_id:{_eq:$userId}}, {notify:{_eq:true}}]},limit:$limit,offset:$offset,order_by:{created_at:desc}){
    created_at
    user_id
    notify
    seen
    source_id
    activity
    action
  }
  
}
""");
    return data['data']['notifications'];
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

  static blockedUsers({bool idOnly}) async {
    int id = await getUserId();

    String doc = idOnly == true
        ? 'blocked_user_id'
        : """blocked_user{
    user_id
    username
    name
    avatar_url

  
  }""";
    dynamic data = await hasuraConnect.query("""
query{
  user_blocks(where:{user_id:{_eq:$id}}){
    
  $doc
  }
  
}""");

    return data['data']['user_blocks'];
  }

  static mutedUsers({bool idOnly}) async {
    int id = await getUserId();
    String doc = idOnly == true
        ? 'muted_user_id'
        : """muted_user{
    user_id
    username
    name
    avatar_url

  
  }""";
    dynamic data = await hasuraConnect.query("""
query{
  user_mutes(where:{user_id:{_eq:$id}}){
  $doc
  }
  
}""");

    return data['data']['user_mutes'];
  }

  static blockUser(int peerId) async {
    int id = await getUserId();
    hasuraConnect.mutation("""
    mutation{
  insert_user_blocks(objects:[{user_id:$id,blocked_user_id:$peerId}]){
    affected_rows
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

    await hasuraConnect.mutation("""mutation{
  delete_user_${info.toString().substring(9)}s_by_pk(user_id:$id,${info.toString().substring(9)}${info == UserInfo.mute ? 'd' : 'ed'}_user_id:$peer){
__typename
  }
}""");
  }

  static insertComment(dynamic postId, String comment, int ownerId,
      {int fakeId}) async {
    int userId = await getUserId();
    if (!kReleaseMode) {
      if (fakeId != null) {
        userId = fakeId;
      }
    }
    comment = comment
        .replaceAll("\n", "\\n")
        .replaceAll('\'', '\\\'')
        .replaceAll('\"', '\\\"');

    String doc = """mutation{
  insert_comments_one(object:{data:"$comment",post_id:$postId,user_id:$userId,}){
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
""";
    dynamic data = await hasuraConnect.mutation(doc);

    return data['data']['insert_comments_one'];
  }

  static insertCommentReply(dynamic postId, int commentId, String text,
      String createdAt, int commenterId) async {
    String doc = """mutation{
  insert_comment_replies_one(object:{comment_id:$commentId,user_id:$commenterId,data:"$text", }){                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
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
    print(doc);

    var data = await hasuraConnect.mutation(doc);
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
      sortString = "score:desc";
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

  static getCommentWithPost(int id) async {
    dynamic comment = await hasuraConnect.query("""query{
  comments(where:{comment_id:{_eq:$id}}){
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
    post{
        contents
    created_at
    owner_id
    post_id
    title
    subtitle
    user{
      avatar_url
      username
    }
    post_tags{
      tg{tag}
    }
     actions_by_user{
      not_interested
      up
      time
    }
       upvote_count
      share_count
      comment_count
      save_count
         downvote_count
    }
   
  }
  
  
  
}
""");
    return comment['data']['comments'][0];
  }

  static getReplyCommentWithPost(int replyId) async {
    dynamic doc = await hasuraConnect.query("""query{
 comment_replies_by_pk(reply_id:$replyId){
    reply_id
    comment{  comment_id
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
    post{
          contents
    created_at
    owner_id
    post_id
    title
    subtitle
      actions_by_user{
      not_interested
      up
      time
    }
    user{
      avatar_url
      username
    }
    post_tags{
      tg{tag}
    }
       upvote_count
      share_count
      comment_count
      save_count
         downvote_count
    }}
    
   
  }
  
  
  
}
""");

    return doc['data']['comment_replies_by_pk']['comment'];
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
    subtitle
    user{
      avatar_url
      username
    }
     actions_by_user{
      not_interested
      up
      time
    }
    post_tags{
      tg{tag}
    }
       downvote_count
       upvote_count
      share_count
      comment_count
      save_count
    }
    
  }
}""");
    return data['data']['saved_posts'];
  }

  static getSaveIds() async {
    dynamic userId = await getUserId();
    dynamic data = await hasuraConnect.query("""query{
  saved_posts(where:{user_id:{_eq:$userId}},order_by:{post:{created_at:desc}}){
    post{
    post_id
    
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
    subtitle
    user{
      avatar_url
      username
    }
    post_tags{
      tg{tag}
    }
     actions_by_user{
      not_interested
      up
      time
    }
       downvote_count
      upvote_count
      share_count
      comment_count
      save_count
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

  static getFollowingPosts(
    int offset,
    int limit,
  ) async {
    int userId = await getUserId();
    String params = 'limit:$limit,offset:$offset';

    dynamic doc = await hasuraConnect.query("""query{
  following_feed($params,where:{user_id:{_eq:$userId}},order_by:{created_at:desc}){
     post{
       contents
    created_at
    owner_id
    post_id
    title
    subtitle
    thumbnail
    actions_by_user{
      not_interested
      up
      time
    }
    comment_count
    user{
      avatar_url
      username
    }
    post_tags{
      tg{tag}
    }
      upvote_count
      share_count
      comment_count
      save_count
         downvote_count
    }
  }
}""");
    return doc['data']['following_feed'];
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

    await hasuraConnect.mutation("""mutation{
  delete_${cr}_votes_by_pk(${r}_id: $id,user_id:$userId){__typename}
}""");
  }

  static insertCommentVote(
    bool reply,
    int id,
    bool vote,
  ) async {
    dynamic userId = await getUserId();
    String cr = reply ? "comment_reply" : "comment";
    String crs = reply ? "comment_replies" : "comments";
    String r = reply ? "reply" : "comment";

    await hasuraConnect.mutation("""
    mutation{
  insert_${cr}_votes_one(object:{user_id:$userId,${r}_id:$id, upvote: $vote, },){
    __typename
  }
}
    """);
  }

  static updateCommentVote(
    bool reply,
    int id,
    bool vote,
  ) async {
    dynamic userId = await getUserId();
    String cr = reply ? "comment_reply" : "comment";
    String crs = reply ? "comment_replies" : "comments";
    String r = reply ? "reply" : "comment";

    await hasuraConnect.mutation("""
    mutation{
  update_${cr}_votes_by_pk(pk_columns:{${r}_id:$id,user_id:$userId},_set:{upvote:$vote}){
   __typename
  }
}
  
    """);
  }

  static messageDeleteForMe(int msgId, bool bySender) async {
    await hasuraConnect.mutation("""mutation{
  update_messages_by_pk(pk_columns:{msg_id:$msgId},_set:{deleted_by_sender:$bySender  }){
    __typename
  }
}""");
  }

  static deleteMessage(
    int msgId,
  ) async {
    await hasuraConnect.mutation("""mutation{
  delete_messages_by_pk(msg_id:$msgId){
    __typename
  }
}""");
  }

  static getPopularTags() async {
    dynamic doc = await hasuraConnect.query("""query{
  tags(order_by:{post_count:desc},limit:100){
    tag_id
    tag
    image_url
    label
  }
}""");
    return doc['data']['tags'];
  }

  static getFollowsUsers(bool following, int profileId) async {
    String text;
    String text1;
    if (following) {
      text = 'following';
      text1 = 'follower';
    } else {
      text = 'follower';
      text1 = 'following';
    }
    dynamic data = await hasuraConnect.query("""query{
  follows(where:{${text1}_id:{_eq:$profileId}}){
    $text{
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
    follower_count
    following_count
    }
  }
  
}""");

    return data['data']['follows'];
  }

  static referrals(bool invitee) async {
    int id = await getUserId();
    return await hasuraConnect.query("""query{
  referral(where:{invite${invitee ? 'e' : 'r'}:{_eq:$id}}){
    __typename
    
  }
}""");
  }

  static redeemCode(String peerId) async {
    int id = await getUserId();
    try {
      await hasuraConnect.mutation("""
     
mutation{
  insert_referral_one(object:{amount:10,invitee:$id,inviter:$peerId}){
    __typename
  }
}

    """);
      snackbar('Code Redeemed Successfully', Get.context);
      return true;
    } catch (e) {
      snackbar('An Error Occurred', Get.context);
      return false;
    }
  }

  static postShareAction(
    int postId,
    bool update,
  ) async {
    int userId = await getUserId();
    String doc = update
        ? """mutation{
  update_post_actions_by_pk(pk_columns:{post_id: $postId,user_id:$userId},_set:{shared:true}){
   __typename
  }
}"""
        : """mutation{
  insert_post_actions_one(object:{user_id:$userId,post_id:$postId,shared:true}){
   __typename
  }
}""";
    await hasuraConnect.mutation(doc);
  }
}
