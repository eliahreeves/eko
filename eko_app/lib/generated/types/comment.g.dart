// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentModel _$CommentModelFromJson(Map<String, dynamic> json) =>
    _CommentModel(
      uid: json['author'] as String,
      id: json['id'] as String,
      postId: json['postId'] as String,
      gifUrl: json['gifUrl'] as String?,
      body: json['body'] == null
          ? const <String>[]
          : parseTextToTags(json['body'] as String?),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      dislikes: (json['dislikes'] as num?)?.toInt() ?? 0,
      createdAt: json['time'] as String,
    );

Map<String, dynamic> _$CommentModelToJson(_CommentModel instance) =>
    <String, dynamic>{
      'author': instance.uid,
      'id': instance.id,
      'postId': instance.postId,
      'gifUrl': instance.gifUrl,
      'body': _joinList(instance.body),
      'likes': instance.likes,
      'dislikes': instance.dislikes,
      'time': instance.createdAt,
    };
