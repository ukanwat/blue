import 'package:hive/hive.dart';

part 'post_like.g.dart';


@HiveType(typeId: 1)
class PostLike{
  @HiveField(0)
  String postId;
  PostLike(this.postId);
}