// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveUserAdapter extends TypeAdapter<HiveUser> {
  @override
  final int typeId = 0;

  @override
  HiveUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveUser(
      fields[0] as int,
      username: fields[1] as String,
      email: fields[2] as String,
      photoUrl: fields[3] as String,
      name: fields[4] as String,
      about: fields[5] as String,
      website: fields[6] as String,
      headerUrl: fields[7] as String,
      avatarUrl: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveUser obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.about)
      ..writeByte(6)
      ..write(obj.website)
      ..writeByte(7)
      ..write(obj.headerUrl)
      ..writeByte(8)
      ..write(obj.avatarUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HivePostAdapter extends TypeAdapter<HivePost> {
  @override
  final int typeId = 1;

  @override
  HivePost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePost(
      fields[0] as int,
      ownerId: fields[1] as dynamic,
      username: fields[2] as String,
      photoUrl: fields[3] as String,
      title: fields[4] as String,
      topicName: fields[5] as String,
      topicId: fields[6] as String,
      contents: (fields[7] as List)?.cast<dynamic>(),
      contentsInfo: (fields[8] as List)?.cast<dynamic>(),
      upvotes: fields[9] as int,
      votes: fields[11] as int,
      downvotes: fields[10] as int,
      tags: (fields[12] as List)?.cast<String>(),
      isCompact: fields[13] as bool,
      commentsShown: fields[14] as bool,
      time: fields[15] as String,
      comments: fields[16] as int,
      saves: fields[17] as int,
      shares: fields[18] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HivePost obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.postId)
      ..writeByte(1)
      ..write(obj.ownerId)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.topicName)
      ..writeByte(6)
      ..write(obj.topicId)
      ..writeByte(7)
      ..write(obj.contents)
      ..writeByte(8)
      ..write(obj.contentsInfo)
      ..writeByte(9)
      ..write(obj.upvotes)
      ..writeByte(10)
      ..write(obj.downvotes)
      ..writeByte(11)
      ..write(obj.votes)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.isCompact)
      ..writeByte(14)
      ..write(obj.commentsShown)
      ..writeByte(15)
      ..write(obj.time)
      ..writeByte(16)
      ..write(obj.comments)
      ..writeByte(17)
      ..write(obj.saves)
      ..writeByte(18)
      ..write(obj.shares);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
