import 'package:eko_app/types/comment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/providers/current_user_provider.dart';
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

Future<(int, List<PollOptionModel>?)> uploadPost(
    PostModel post, List<String>? pollOptions, WidgetRef ref) async {
  final fixedPost = post.copyWith(
    createdAt: DateTime.now().toUtc().toIso8601String(),
  );
  final uid = ref.read(currentUserProvider).user.uid;

  final result = await supabase.rpc('insert_post', params: {
    'p_created_at': fixedPost.createdAt,
    'p_author_uid': uid,
    'p_title': fixedPost.title.isNotEmpty ? fixedPost.title.join('') : null,
    'p_body': fixedPost.body.isNotEmpty ? fixedPost.body.join('') : null,
    'p_gif': fixedPost.gifUrl,
    'p_poll': pollOptions,
    'p_image_base64': fixedPost.imageString?.toStorableString(),
    'p_ekoed_id': fixedPost.repostId,
  });

  final row = result as Map;
  final postId = (row['o_post_id'] as num).toInt();
  final rawPoll = row['o_poll_data'] as List?;
  final List<PollOptionModel>? poll;
  if (rawPoll != null) {
    poll = rawPoll.map((v) => PollOptionModel.fromJson(v)).toList();
  } else {
    poll = null;
  }

  return (postId, poll);
}

Future<int> uploadComment(CommentModel comment, WidgetRef ref) async {
  final json = comment.toJson();
  final uid = ref.read(currentUserProvider).user.uid;

  json.remove('id');
  json.remove('postId');

  final result = await supabase.rpc('insert_comment', params: {
    'p_created_at': comment.createdAt,
    'p_author_uid': uid,
    'p_body': json['body'],
    'p_gif': json['gifUrl'],
    'p_parent_post_id': comment.postId,
  });

  return result;
}
