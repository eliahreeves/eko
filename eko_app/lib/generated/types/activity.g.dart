// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityModel _$ActivityModelFromJson(Map<String, dynamic> json) =>
    _ActivityModel(
      sourceUid: json['source_uid'] as String,
      id: (json['id'] as num).toInt(),
      postId: (json['post_id'] as num?)?.toInt(),
      commentId: (json['comment_id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$ActivityModelToJson(_ActivityModel instance) =>
    <String, dynamic>{
      'source_uid': instance.sourceUid,
      'id': instance.id,
      'post_id': instance.postId,
      'comment_id': instance.commentId,
      'created_at': instance.createdAt,
      'type': _$ActivityTypeEnumMap[instance.type]!,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.postTag: 'post_tag',
  ActivityType.commentTag: 'comment_tag',
  ActivityType.follow: 'follow',
  ActivityType.comment: 'comment',
  ActivityType.eko: 'eko',
};
