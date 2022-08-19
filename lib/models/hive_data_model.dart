// Package imports:
import 'package:hive/hive.dart';

part 'hive_data_model.g.dart';

//USE        flutter pub run build_runner build
@HiveType(typeId: 0)
class HiveUser extends HiveObject {
  @HiveField(0)
  int userId;
  @HiveField(1)
  String username;
  @HiveField(2)
  String email;
  @HiveField(3)
  String photoUrl;
  @HiveField(4)
  String name;
  @HiveField(5)
  String about;
  @HiveField(6)
  String website;
  @HiveField(7)
  String headerUrl;
  @HiveField(8)
  String avatarUrl;
  HiveUser(this.userId,
      {this.username,
      this.email,
      this.photoUrl,
      this.name,
      this.about,
      this.website,
      this.headerUrl,
      this.avatarUrl});
}

@HiveType(typeId: 1)
class HivePost extends HiveObject {
  @HiveField(0)
  int postId;
  @HiveField(1)
  dynamic ownerId;
  @HiveField(2)
  String username;
  @HiveField(3)
  String photoUrl;
  @HiveField(4)
  String title;
  @HiveField(5)
  String topicName;
  @HiveField(6)
  String topicId;
  @HiveField(7)
  List contents;
  @HiveField(8)
  List contentsInfo;
  @HiveField(9)
  int upvotes;
  @HiveField(10)
  int downvotes;
  @HiveField(11)
  int votes;
  @HiveField(12)
  List<String> tags;
  @HiveField(13)
  bool isCompact;
  @HiveField(14)
  bool commentsShown;
  @HiveField(15)
  String time; //TODO: unsure of the type
  @HiveField(16)
  int comments;
  @HiveField(17)
  int saves;
  @HiveField(18)
  int shares;

  HivePost(this.postId,
      {this.ownerId,
      this.username,
      this.photoUrl,
      this.title,
      this.topicName,
      this.topicId,
      this.contents,
      this.contentsInfo,
      this.upvotes,
      this.votes,
      this.downvotes,
      this.tags,
      this.isCompact,
      this.commentsShown, // this.postInteractions
      this.time,
      this.comments,
      this.saves,
      this.shares});
}
