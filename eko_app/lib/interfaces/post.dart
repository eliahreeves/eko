import 'package:eko_app/providers/post_provider.dart';
import 'package:eko_app/types/comment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/interfaces/activity.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/types/activity.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/utilities/supabase_ref.dart';

// Converts a String to the List<String> eko tag format.
List<String> parseTextToTags(String? text) {
  if (text == null) return [];

  RegExp regExp = RegExp(r'@[a-z0-9_]{3,24}', caseSensitive: false);
  List<String> chunks = [];
  int lastEnd = 0;

  regExp.allMatches(text).forEach((match) {
    // Add the chunk of text before the match to the list
    String precedingText = text.substring(lastEnd, match.start);
    if (precedingText.isNotEmpty) {
      chunks.add(precedingText);
    } else if (chunks.isNotEmpty && chunks.last.startsWith('@')) {
      // If the last chunk was a username, add an empty string
      chunks.add('');
    }
    // Add the match itself
    chunks.add(match.group(0)!);
    lastEnd = match.end;
  });

  // If there's any text left after the last match, add this remaining text to the list
  if (lastEnd < text.length) {
    chunks.add(text.substring(lastEnd));
  }
  return chunks;
}

Future<int> uploadPost(PostModel post, WidgetRef ref) async {
  final fixedPost = post.copyWith(
    createdAt: DateTime.now().toUtc().toIso8601String(),
  );
  final uid = ref.read(currentUserProvider).user.uid;

  dynamic result;
  result = await supabase.rpc('insert_post', params: {
    'p_created_at': fixedPost.createdAt,
    'p_author_uid': uid,
    'p_firebase_uid': null,
    'p_title': fixedPost.title.isNotEmpty ? fixedPost.title.join('') : null,
    'p_body': fixedPost.body.isNotEmpty ? fixedPost.body.join('') : null,
    'p_gif': fixedPost.gifUrl,
    'p_poll': fixedPost.pollOptions,
    'p_image_base64': fixedPost.imageString?.toStorableString(),
    'p_ekoed_id': fixedPost.repostId,
    'p_chamber_id': null,
  });

  final row = (result as List).first as Map;
  if (row['success'] != true) throw Exception(row['error_message']);
  final postId = (row['post_id'] as num).toInt();

  final List<Future<String?>> idFutures = [];
  for (int i = 1; i < post.title.length; i += 2) {
    idFutures.add(getUidFromUsername(post.title[i].substring(1)));
  }
  for (int i = 1; i < post.body.length; i += 2) {
    idFutures.add(getUidFromUsername(post.body[i].substring(1)));
  }

  late final String content;
  final titleStr = fixedPost.title.join('');
  final bodyStr = fixedPost.body.join('');
  if (titleStr.isNotEmpty) {
    content = titleStr;
  } else if (bodyStr.isNotEmpty) {
    content = bodyStr;
  } else {
    content = '${post.uid} tagged you in a post';
  }

  final taggedUsers = await Future.wait(idFutures);
  final Set<String> sentActivities = {ref.read(currentUserProvider).user.uid};
  final List<Future<void>> activityFutures = [];

  for (final user in taggedUsers) {
    if (user == null) continue;
    if (sentActivities.contains(user)) continue;
    sentActivities.add(user);

    final activity = ActivityModel(
      id: '',
      createdAt: post.createdAt,
      type: 'tag',
      content: content,
      path: postId.toString(),
      sourceUid: post.uid,
    );
    activityFutures.add(uploadActivity(activity, user));
  }

  return postId;
}

Future<int> uploadComment(CommentModel comment, WidgetRef ref) async {
  final json = comment.toJson();
  final post = await ref.read(postProvider(comment.postId).future);
  final uid = ref.read(currentUserProvider).user.uid;

  json.remove('id');
  json.remove('postId');

  final result = await supabase.rpc('insert_comment', params: {
    'p_created_at': comment.createdAt,
    'p_author_uid': uid,
    'p_firebase_uid': null,
    'p_body': json['body'],
    'p_gif': json['gifUrl'],
    'p_parent_post_id': comment.postId,
  });
  final row = (result as List).first as Map;
  if (row['success'] != true) throw Exception(row['error_message']);
  final commentId = (row['comment_id'] as num).toInt();

  if (ref.watch(currentUserProvider).user.uid != post.uid) {
    final activity = ActivityModel(
      id: '',
      createdAt: comment.createdAt,
      type: 'comment',
      content: json['body'] ?? 'Click to see gif',
      path: comment.postId.toString(),
      sourceUid: comment.uid,
    );

    uploadActivity(activity, post.uid);
  }

  // get users tagged in the comment
  final List<Future<String?>> idFutures = [];
  for (int i = 1; i < comment.body.length; i += 2) {
    idFutures.add(getUidFromUsername(comment.body[i].substring(1)));
  }

  // activity content
  final String content = json['body'];

  final taggedUsers = await Future.wait(idFutures);

  // make sure not to notify yourself
  final Set<String> sentActivites = {ref.watch(currentUserProvider).user.uid};
  final List<Future<void>> activityFutures = [];

  for (final user in taggedUsers) {
    if (user == null) {
      continue;
    }
    if (sentActivites.contains(user)) {
      continue;
    }
    sentActivites.add(user);

    final activity = ActivityModel(
      id: '',
      createdAt: comment.createdAt,
      type: 'tag',
      content: content,
      path: comment.postId.toString(),
      sourceUid: comment.uid,
    );
    activityFutures.add(uploadActivity(activity, user));
  }

  return commentId;
}
