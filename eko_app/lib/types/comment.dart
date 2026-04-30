import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:eko_app/interfaces/post.dart';
part '../generated/types/comment.freezed.dart';
part '../generated/types/comment.g.dart';

String _joinList(List<String>? list) {
  if (list == null) {
    return '';
  }
  return list.join('');
}

List<String> _parseTags(Object? value) {
  if (value == null) return [];
  if (value is String) return parseTextToTags(value);
  if (value is List) return value.map((item) => item.toString()).toList();
  return parseTextToTags(value.toString());
}

@freezed
abstract class CommentModel with _$CommentModel {
  const CommentModel._();
  const factory CommentModel({
    @JsonKey(name: 'author_uid') required String uid,
    required int id,
    @JsonKey(name: 'parent_post_id') required int postId,
    @JsonKey(name: 'gif') String? gifUrl,
    @Default(<String>[])
    @JsonKey(fromJson: _parseTags, toJson: _joinList)
    List<String> body,
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

  static Future<CommentModel> fromFireStoreDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final json = doc.data();
    json['id'] = int.tryParse(doc.id);
    json['parent_post_id'] =
        int.tryParse(doc.reference.parent.parent?.id ?? '');
    return CommentModel.fromJson(json);
  }
}
