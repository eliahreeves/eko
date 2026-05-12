// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentModel _$CommentModelFromJson(Map<String, dynamic> json) =>
    _CommentModel(
      uid: json['author_uid'] as String,
      id: (json['id'] as num).toInt(),
      postId: (json['parent_post_id'] as num).toInt(),
      gifUrl: json['gif'] as String?,
      body: json['body'] as String?,
      likes: (json['like_count'] as num?)?.toInt() ?? 0,
      dislikes: (json['dislike_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isDisliked: json['is_disliked'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$CommentModelToJson(_CommentModel instance) =>
    <String, dynamic>{
      'author_uid': instance.uid,
      'id': instance.id,
      'parent_post_id': instance.postId,
      'gif': instance.gifUrl,
      'body': instance.body,
      'like_count': instance.likes,
      'dislike_count': instance.dislikes,
      'is_liked': instance.isLiked,
      'is_disliked': instance.isDisliked,
      'created_at': instance.createdAt,
    };
