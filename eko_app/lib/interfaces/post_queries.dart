import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/types/comment.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/supabase_post_mapper.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<(List<MapEntry<String, String>>, bool)> profilePageGetter(
  List<MapEntry<String, String>> list,
  WidgetRef ref,
) async {
  final uid = ref.read(currentUserProvider).user.uid;
  final params = <String, dynamic>{
    'p_limit': c.postsOnRefresh,
    'p_user_uid': uid,
  };
  if (list.isNotEmpty) {
    params['p_last_time'] = list.last.value;
    params['p_last_id'] = int.parse(list.last.key);
  }
  final rows = await supabase.rpc('paginated_user_posts', params: params);
  final postList = postModelsFromSupabaseRpc(rows as List<dynamic>?);
  ref.read(postPoolProvider).putAll(postList);
  final retList =
      postList.map((item) => MapEntry(item.id, item.createdAt)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<(List<MapEntry<String, String>>, bool)> otherProfilePageGetter(
  List<MapEntry<String, String>> list,
  WidgetRef ref,
  String uid,
) async {
  final params = <String, dynamic>{
    'p_limit': c.postsOnRefresh,
    'p_user_uid': uid,
  };
  if (list.isNotEmpty) {
    params['p_last_time'] = list.last.value;
    params['p_last_id'] = int.parse(list.last.key);
  }
  final rows = await supabase.rpc('paginated_user_posts', params: params);
  final postList = postModelsFromSupabaseRpc(rows as List<dynamic>?)
      .where((p) => p.tags.contains('public'))
      .toList();
  ref.read(postPoolProvider).putAll(postList);
  final retList =
      postList.map((item) => MapEntry(item.id, item.createdAt)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<(List<MapEntry<String, (int, String)>>, bool)> popGetter(
  List<MapEntry<String, (int, String)>> list,
  WidgetRef ref,
) async {
  final params = <String, dynamic>{
    'p_limit': c.postsOnRefresh,
  };
  if (list.isNotEmpty) {
    params['p_last_likes'] = list.last.value.$1;
    params['p_last_id'] = int.parse(list.last.key);
  }
  final rows = await supabase.rpc('paginated_popular_posts', params: params);
  final postList = postModelsFromSupabaseRpc(rows as List<dynamic>?);
  ref.read(postPoolProvider).putAll(postList);
  final retList =
      postList.map((item) => MapEntry(item.id, (item.likes, item.id))).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<(List<MapEntry<String, String>>, bool)> getGroupPosts(
  List<MapEntry<String, String>> list,
  WidgetRef ref,
  String groupId,
) async {
  final chamberId = int.tryParse(groupId);
  if (chamberId == null) {
    return (<MapEntry<String, String>>[], true);
  }
  final params = <String, dynamic>{
    'p_limit': c.postsOnRefresh,
    'p_chamber_id': chamberId,
  };
  if (list.isNotEmpty) {
    params['p_last_time'] = list.last.value;
    params['p_last_id'] = int.parse(list.last.key);
  }
  final rows = await supabase.rpc('paginated_chamber_posts', params: params);
  final postList = postModelsFromSupabaseRpc(rows as List<dynamic>?);
  ref.read(postPoolProvider).putAll(postList);
  final retList =
      postList.map((item) => MapEntry(item.id, item.createdAt)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<List<CommentModel>> getCommentsForPost(
  String postId, {
  String? lastTime,
  int? lastId,
}) async {
  final parentId = int.tryParse(postId);
  if (parentId == null) {
    return [];
  }
  final params = <String, dynamic>{
    'p_limit': c.postsOnRefresh,
    'p_parent_post_id': parentId,
  };
  if (lastTime != null && lastId != null) {
    params['p_last_time'] = lastTime;
    params['p_last_id'] = lastId;
  }
  final rows = await supabase.rpc('paginated_comments', params: params);
  return commentModelsFromSupabaseRpc(rows as List<dynamic>?);
}
