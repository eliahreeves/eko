import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
part '../generated/types/post.freezed.dart';
part '../generated/types/post.g.dart';

String? _asciiImageToString(AsciiImage? image) {
  if (image == null) return null;
  return image.toStorableString();
}

AsciiImage? _asciiImageFromString(String? image) {
  if (image == null) return null;
  return AsciiImage.fromStorableString(image);
}

@freezed
abstract class PostModel with _$PostModel {
  const PostModel._();
  const factory PostModel({
    @JsonKey(name: 'author_uid') required String uid,
    required int id,
    @JsonKey(name: 'gif') String? gifUrl,
    @JsonKey(
      name: 'image',
      fromJson: _asciiImageFromString,
      toJson: _asciiImageToString,
    )
    AsciiImage? imageString,
    String? title,
    String? body,
    @Default(['public']) List<String> tags,
    @Default(0) @JsonKey(name: 'like_count') int likes,
    @Default(0) @JsonKey(name: 'dislike_count') int dislikes,
    @Default(0) @JsonKey(name: 'comment_count') int commentCount,
    @Default(false) @JsonKey(name: 'is_liked') bool isLiked,
    @Default(false) @JsonKey(name: 'is_disliked') bool isDisliked,
    @JsonKey(name: 'created_at') required String createdAt,
    List<PollOptionModel>? poll,
    int? vote,
    @JsonKey(name: 'ekoed_id') int? repostId,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  DateTime getDateTime() {
    return DateTime.tryParse(createdAt) ?? DateTime.now();
  }
}

@freezed
abstract class PollOptionModel with _$PollOptionModel {
  const factory PollOptionModel({
    required String value,
    @JsonKey(name: 'option_id') required int optionId,
    @JsonKey(name: 'vote_count') required int voteCount,
  }) = _PollOptionModel;

  factory PollOptionModel.fromJson(Map<String, dynamic> json) =>
      _$PollOptionModelFromJson(json);
}
