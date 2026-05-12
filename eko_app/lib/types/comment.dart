import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/comment.freezed.dart';
part '../generated/types/comment.g.dart';

@freezed
abstract class CommentModel with _$CommentModel {
  const CommentModel._();
  const factory CommentModel({
    @JsonKey(name: 'author_uid') required String uid,
    required int id,
    @JsonKey(name: 'parent_post_id') required int postId,
    @JsonKey(name: 'gif') String? gifUrl,
    String? body,
    @Default(0) @JsonKey(name: 'like_count') int likes,
    @Default(0) @JsonKey(name: 'dislike_count') int dislikes,
    @Default(false) @JsonKey(name: 'is_liked') bool isLiked,
    @Default(false) @JsonKey(name: 'is_disliked') bool isDisliked,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  DateTime getDateTime() {
    return DateTime.tryParse(createdAt) ?? DateTime.now();
  }
}
