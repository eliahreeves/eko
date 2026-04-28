import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/supabase_post_mapper.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ProfilePostListState = (List<String>, bool);

class ProfilePostListNotifier extends StateNotifier<ProfilePostListState> {
  ProfilePostListNotifier(this.ref) : super(([], false));

  final Ref ref;
  final List<MapEntry<String, String>> _cursors = [];
  final Set<String> _set = {};

  Future<void> getter() async {
    final params = <String, dynamic>{
      'p_limit': c.postsOnRefresh,
      'p_user_uid': ref.read(currentUserProvider).user.uid,
    };
    if (_cursors.isNotEmpty) {
      params['p_last_time'] = _cursors.last.value;
      params['p_last_id'] = int.parse(_cursors.last.key);
    }
    final rows = await supabase.rpc('paginated_user_posts', params: params);
    final posts = postModelsFromSupabaseRpc(rows as List<dynamic>?);
    ref.read(postPoolProvider).putAll(posts);

    final newList = [...state.$1];
    for (final post in posts) {
      if (_set.add(post.id)) {
        newList.add(post.id);
        _cursors.add(MapEntry(post.id, post.createdAt));
      }
    }
    state = (newList, posts.length < c.postsOnRefresh);
  }

  Future<void> refresh() async {
    _set.clear();
    _cursors.clear();
    state = ([], false);
    await getter();
  }

  void removePost(String postId) {
    final newList = [...state.$1];
    final removed = newList.remove(postId);
    if (removed) {
      _set.remove(postId);
      _cursors.removeWhere((entry) => entry.key == postId);
      state = (newList, state.$2);
    }
  }
}

class OtherProfilePostListNotifier extends StateNotifier<ProfilePostListState> {
  OtherProfilePostListNotifier(this.ref, this.uid) : super(([], false));

  final Ref ref;
  final String uid;
  final List<MapEntry<String, String>> _cursors = [];
  final Set<String> _set = {};

  Future<void> getter() async {
    final params = <String, dynamic>{
      'p_limit': c.postsOnRefresh,
      'p_user_uid': uid,
    };
    if (_cursors.isNotEmpty) {
      params['p_last_time'] = _cursors.last.value;
      params['p_last_id'] = int.parse(_cursors.last.key);
    }
    final rows = await supabase.rpc('paginated_user_posts', params: params);
    final posts = postModelsFromSupabaseRpc(rows as List<dynamic>?)
        .where((post) => post.tags.contains('public'))
        .toList();
    ref.read(postPoolProvider).putAll(posts);

    final newList = [...state.$1];
    for (final post in posts) {
      if (_set.add(post.id)) {
        newList.add(post.id);
        _cursors.add(MapEntry(post.id, post.createdAt));
      }
    }
    state = (newList, posts.length < c.postsOnRefresh);
  }

  Future<void> refresh() async {
    _set.clear();
    _cursors.clear();
    state = ([], false);
    await getter();
  }
}

final profilePostListProvider =
    StateNotifierProvider<ProfilePostListNotifier, ProfilePostListState>(
      (ref) => ProfilePostListNotifier(ref),
    );

final otherProfilePostListProvider = StateNotifierProvider.family<
  OtherProfilePostListNotifier,
  ProfilePostListState,
  String
>((ref, uid) => OtherProfilePostListNotifier(ref, uid));
