import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/interfaces/post_queries.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/types/comment.dart';
import 'package:eko_app/utilities/constants.dart' as c;
part '../generated/providers/comment_list_provider.g.dart';

@riverpod
class CommentList extends _$CommentList {
  String? _lastTime;
  int? _lastId;
  Future<void>? _ongoingFetch;
  @override
  (List<int>, bool) build(int postId) {
    return ([], false);
  }

  Future<void> getter(int postId) async {
    // wait for a current call to finish to prevent dup network calls and dup comments
    // previously InfiniteScrolly was calling the getter as a result of refresh being
    // called when the state was set to 0 comments and a scroll was happening
    if (_ongoingFetch != null) {
      await _ongoingFetch;
      return;
    }

    _ongoingFetch = () async {
      try {
        final commentList = await getCommentsForPost(
          postId,
          lastTime: _lastTime,
          lastId: _lastId,
        );
        ref.read(commentPoolProvider).putAll(commentList);

        final newList = [...state.$1];
        for (final comment in commentList) {
          // deduplicate comments
          if (!newList.contains(comment.id)) {
            newList.add(comment.id);
          }
          _lastTime = comment.createdAt;
          _lastId = comment.id;
        }
        state = (newList, commentList.length < c.postsOnRefresh);
      } finally {
        _ongoingFetch = null;
      }
    }();

    await _ongoingFetch;
  }

  Future<void> refresh() async {
    _lastTime = null;
    _lastId = null;
    state = ([], false);
    await getter(postId);
  }

  void insertAtIndex(int index, CommentModel comment) {
    final newList = [...state.$1];
    newList.insert(index, comment.id);
    state = (newList, state.$2);
  }

  void addToBack(CommentModel comment) {
    final currentLength = state.$1.length;
    insertAtIndex(currentLength, comment);
  }

  void removeById(int id) {
    state = (state.$1.where((commentId) => commentId != id).toList(), state.$2);
  }
}
