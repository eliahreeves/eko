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

@freezed
abstract class CommentModel with _$CommentModel {
  const CommentModel._();
  const factory CommentModel({
    @JsonKey(name: 'author') required String uid,
    required String id,
    required String postId,
    String? gifUrl,
    @Default(<String>[])
    @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
    List<String> body,
    @Default(0) int likes,
    @Default(0) int dislikes,
    @JsonKey(name: 'time') required String createdAt,
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
    json['id'] = doc.id;
    json['postId'] = doc.reference.parent.parent?.id;
    return CommentModel.fromJson(json);
  }
}
