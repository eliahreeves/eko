// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostModel _$PostModelFromJson(Map<String, dynamic> json) => _PostModel(
      uid: json['author'] as String,
      id: (json['id'] as num).toInt(),
      gifUrl: json['gifUrl'] as String?,
      imageString: _asciiImageFromString(json['image'] as String?),
      title: json['title'] == null
          ? const <String>[]
          : parseTextToTags(json['title'] as String?),
      body: json['body'] == null
          ? const <String>[]
          : parseTextToTags(json['body'] as String?),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const ['public'],
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      dislikes: (json['dislikes'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isDisliked: json['isDisliked'] as bool? ?? false,
      createdAt: json['time'] as String,
      poll: (json['poll'] as List<dynamic>?)
          ?.map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      vote: (json['vote'] as num?)?.toInt(),
      repostId: (json['repostId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PostModelToJson(_PostModel instance) =>
    <String, dynamic>{
      'author': instance.uid,
      'id': instance.id,
      'gifUrl': instance.gifUrl,
      'image': _asciiImageToString(instance.imageString),
      'title': _joinList(instance.title),
      'body': _joinList(instance.body),
      'tags': instance.tags,
      'likes': instance.likes,
      'dislikes': instance.dislikes,
      'commentCount': instance.commentCount,
      'isLiked': instance.isLiked,
      'isDisliked': instance.isDisliked,
      'time': instance.createdAt,
      'poll': instance.poll,
      'vote': instance.vote,
      'repostId': instance.repostId,
    };

_PollOptionModel _$PollOptionModelFromJson(Map<String, dynamic> json) =>
    _PollOptionModel(
      value: json['value'] as String,
      optionId: (json['option_id'] as num).toInt(),
      voteCount: (json['vote_count'] as num).toInt(),
    );

Map<String, dynamic> _$PollOptionModelToJson(_PollOptionModel instance) =>
    <String, dynamic>{
      'value': instance.value,
      'option_id': instance.optionId,
      'vote_count': instance.voteCount,
    };
