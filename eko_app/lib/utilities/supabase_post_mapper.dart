import 'package:eko_app/types/comment.dart';
import 'package:eko_app/types/post.dart';

String _asString(dynamic v) {
  if (v == null) {
    return '';
  }
  if (v is String) {
    return v;
  }
  return v.toString();
}

String _createdAtIso(dynamic v) {
  if (v == null) {
    return DateTime.now().toUtc().toIso8601String();
  }
  if (v is String) {
    return v;
  }
  if (v is DateTime) {
    return v.toUtc().toIso8601String();
  }
  return v.toString();
}

/// Maps a row from [full_post_info] / post RPCs to [PostModel].
PostModel postModelFromSupabaseRow(Map<String, dynamic> row) {
  final chamberId = row['chamber_id'];
  final tags =
      chamberId == null ? <String>['public'] : <String>[_asString(chamberId)];
  final ekoedId = row['ekoed_id'];
  final json = <String, dynamic>{
    'author': _asString(row['author_uid']),
    'id': _asString(row['id']),
    'gifUrl': row['gif'] as String?,
    'image': row['image'] as String?,
    'title': row['title'] as String?,
    'body': row['body'] as String?,
    'tags': tags,
    'likes': (row['like_count'] as num?)?.toInt() ?? 0,
    'dislikes': (row['dislike_count'] as num?)?.toInt() ?? 0,
    'commentCount': (row['comment_count'] as num?)?.toInt() ?? 0,
    'time': _createdAtIso(row['created_at']),
  };
  if (ekoedId != null) {
    json['repostId'] = _asString(ekoedId);
  }
  return PostModel.fromJson(json);
}

List<PostModel> postModelsFromSupabaseRpc(List<dynamic>? rows) {
  if (rows == null) {
    return [];
  }
  return rows
      .map((e) => postModelFromSupabaseRow(Map<String, dynamic>.from(e as Map)))
      .toList();
}

CommentModel commentModelFromSupabaseRow(Map<String, dynamic> row) {
  return CommentModel.fromJson({
    'author': _asString(row['author_uid']),
    'id': _asString(row['id']),
    'postId': _asString(row['parent_post_id']),
    'gifUrl': row['gif'] as String?,
    'body': row['body'] as String?,
    'likes': (row['like_count'] as num?)?.toInt() ?? 0,
    'dislikes': (row['dislike_count'] as num?)?.toInt() ?? 0,
    'time': _createdAtIso(row['created_at']),
  });
}

List<CommentModel> commentModelsFromSupabaseRpc(List<dynamic>? rows) {
  if (rows == null) {
    return [];
  }
  return rows
      .map(
        (e) => commentModelFromSupabaseRow(Map<String, dynamic>.from(e as Map)),
      )
      .toList();
}
