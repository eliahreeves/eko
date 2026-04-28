import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/providers/following_feed_provider.dart';
import 'package:eko_app/providers/new_feed_provider.dart';
import 'package:eko_app/providers/profile_post_list_provider.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/utilities/supabase_post_mapper.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
// Necessary for code-generation to work
part '../generated/providers/post_provider.g.dart';

@riverpod
class Post extends _$Post {
  Timer? _disposeTimer;
  bool _isLiking = false;
  bool _isVoting = false;
  @override
  FutureOr<PostModel> build(String id) {
    // *** This block is for lifecycle management *** //
    // Keep provider alive
    final link = ref.keepAlive();
    ref.onCancel(() {
      // Start a 3-minute countdown when the last listener goes away
      _disposeTimer = Timer(const Duration(minutes: 3), () {
        link.close();
      });
    });
    ref.onResume(() {
      // Cancel the timer if a listener starts again
      _disposeTimer?.cancel();
    });
    ref.onDispose(() {
      // ckean up if the provider is somehow disposed
      _disposeTimer?.cancel();
    });
    // ********************************************* //
    // await Future.delayed(Duration(seconds: 100));
    final cacheValue = ref.read(postPoolProvider).getItem(id);
    if (cacheValue != null) {
      return cacheValue;
    }

    return _fetchPostModel(id);
  }

  Future<PostModel> _fetchPostModel(String id) async {
    final parsed = int.tryParse(id);
    if (parsed == null) {
      throw Exception('Failed to load');
    }
    final rows = await supabase.rpc('get_post_by_id', params: {'p_id': parsed});
    final list = rows as List<dynamic>?;
    if (list == null || list.isEmpty) {
      throw Exception('Failed to load');
    }
    return postModelFromSupabaseRow(
      Map<String, dynamic>.from(list.first as Map),
    );
  }

  Future<void> _changePostLike(
    String id, {
    required bool isLiking,
    required bool isDislike,
  }) async {
    await supabase.rpc('change_post_likes', params: {
      'p_id': int.parse(id),
      'p_is_liking': isLiking,
      'p_is_dislike': isDislike,
    });
  }

  Future<void> likePostToggle() async {
    final prevState = await future;
    if (_isLiking) return;
    _isLiking = true;
    if (prevState.isLiked) {
      state = AsyncData(prevState.copyWith(isLiked: false, likes: prevState.likes - 1));
      try {
        await _changePostLike(prevState.id, isLiking: false, isDislike: false);
      } catch (e) {
        debugPrint('likePostToggle unlike error: $e');
        state = AsyncData(prevState);
      }
    } else {
      if (prevState.isDisliked) {
        state = AsyncData(prevState.copyWith(
          isLiked: true,
          isDisliked: false,
          likes: prevState.likes + 1,
          dislikes: prevState.dislikes - 1,
        ));
      } else {
        state = AsyncData(prevState.copyWith(isLiked: true, likes: prevState.likes + 1));
      }
      try {
        await _changePostLike(prevState.id, isLiking: true, isDislike: false);
      } catch (e) {
        debugPrint('likePostToggle like error: $e');
        state = AsyncData(prevState);
      }
    }
    _isLiking = false;
  }

  Future<void> dislikePostToggle() async {
    final prevState = await future;
    if (_isLiking) return;
    _isLiking = true;
    if (prevState.isDisliked) {
      state = AsyncData(prevState.copyWith(isDisliked: false, dislikes: prevState.dislikes - 1));
      try {
        await _changePostLike(prevState.id, isLiking: false, isDislike: true);
      } catch (e) {
        debugPrint('dislikePostToggle undislike error: $e');
        state = AsyncData(prevState);
      }
    } else {
      if (prevState.isLiked) {
        state = AsyncData(prevState.copyWith(
          isDisliked: true,
          isLiked: false,
          dislikes: prevState.dislikes + 1,
          likes: prevState.likes - 1,
        ));
      } else {
        state = AsyncData(prevState.copyWith(isDisliked: true, dislikes: prevState.dislikes + 1));
      }
      try {
        await _changePostLike(prevState.id, isLiking: true, isDislike: true);
      } catch (e) {
        debugPrint('dislikePostToggle dislike error: $e');
        state = AsyncData(prevState);
      }
    }
    _isLiking = false;
  }

  Future<void> _addVoteToDb(String id, int optionIndex) async {
    final firestore = FirebaseFirestore.instance;
    final uid = ref.read(currentUserProvider).user.uid;
    await Future.wait([
      firestore.collection('users').doc(uid).update({
        'profileData.pollVotes.$id': optionIndex,
      }),
      firestore.collection('posts').doc(id).update({
        'pollVoteCounts.$optionIndex': FieldValue.increment(1),
      }),
    ]);
  }

  Future<void> _removeVoteFromDb(String id, int currentVote) async {
    final firestore = FirebaseFirestore.instance;
    final uid = ref.read(currentUserProvider).user.uid;
    await Future.wait([
      firestore.collection('users').doc(uid).update({
        'profileData.pollVotes.$id': FieldValue.delete(),
      }),
      firestore.collection('posts').doc(id).update({
        'pollVoteCounts.$currentVote': FieldValue.increment(-1),
      }),
    ]);
  }

  Future<void> addPollVote({required int optionIndex}) async {
    final prevState = await future;
    if (_isVoting ||
        ref.read(currentUserProvider).pollVotes.containsKey(prevState.id)) {
      return;
    }
    _isVoting = true;

    ref
        .read(currentUserProvider.notifier)
        .addPollVote(prevState.id, optionIndex);

    final updatedPollVoteCounts = Map<String, int>.from(
      prevState.pollVoteCounts ?? {},
    );
    updatedPollVoteCounts[optionIndex.toString()] =
        (updatedPollVoteCounts[optionIndex.toString()] ?? 0) + 1;

    state = AsyncData(
      prevState.copyWith(pollVoteCounts: updatedPollVoteCounts),
    );

    try {
      await _addVoteToDb(prevState.id, optionIndex);
    } catch (_) {
      ref.read(currentUserProvider.notifier).removePollVote(prevState.id);
      state = AsyncData(prevState);
    }

    _isVoting = false;
  }

  Future<void> removePollVote() async {
    final prevState = await future;
    if (_isVoting ||
        !ref.read(currentUserProvider).pollVotes.containsKey(prevState.id)) {
      return;
    }
    _isVoting = true;
    final currentVote = ref.read(currentUserProvider).pollVotes[prevState.id]!;

    ref.read(currentUserProvider.notifier).removePollVote(prevState.id);

    final updatedPollVoteCounts = Map<String, int>.from(
      prevState.pollVoteCounts!,
    );
    updatedPollVoteCounts[currentVote.toString()] =
        (updatedPollVoteCounts[currentVote.toString()] ?? 1) - 1;

    state = AsyncData(
      prevState.copyWith(pollVoteCounts: updatedPollVoteCounts),
    );

    try {
      await _removeVoteFromDb(prevState.id, currentVote);
    } catch (_) {
      ref.read(currentUserProvider.notifier).removePollVote(prevState.id);
      state = AsyncData(prevState);
    }

    _isVoting = false;
  }

  Future<void> deletePost() async {
    final currentPost = await future;
    final postId = currentPost.id;

    try {
      final parsedPostId = int.tryParse(postId);
      if (parsedPostId == null) {
        throw Exception('Failed to delete post');
      }
      await supabase.from('posts').delete().eq('id', parsedPostId);
      ref.read(followingFeedProvider.notifier).removePost(postId);
      ref.read(newFeedProvider.notifier).removePost(postId);
      ref.read(profilePostListProvider.notifier).removePost(postId);
    } catch (e) {
      rethrow;
    }
  }
}
