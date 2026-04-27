import 'dart:io';

import 'package:flutter/material.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:eko_app/interfaces/activity.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/types/current_user.dart';
import 'package:eko_app/types/activity.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/utilities/supabase_user_map.dart';

// Necessary for code-generation to work
part '../generated/providers/current_user_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  @override
  // This is nullable instead of async so that we can just bang it. Await will happen inside the require auth widget.
  CurrentUserModel build() {
    final auth = ref.watch(authProvider);
    // If uid is null, wait for authProvider to emit a non-null uid
    if (auth.uid != null) {
      reload();
    }
    return CurrentUserModel.loading();
  }

  Future<void> editProfile({
    String? name,
    String? bio,
    String? username,
    File? profilePicture,
    String? verificationUrl,
  }) async {
    final prev = state.user;
    state = state.copyWith(
      user: state.user.copyWith(
        name: name ?? prev.name,
        bio: bio ?? prev.bio,
        verificationUrl: verificationUrl ?? prev.verificationUrl,
        isVerified:
            verificationUrl == prev.verificationUrl ? prev.isVerified : false,
      ),
    );

    try {
      String? pic;
      if (profilePicture != null) {
        pic = await _uploadProfilePicture(profilePicture);
        if (pic != null) {
          state = state.copyWith(
            user: state.user.copyWith(profilePicture: pic),
          );
        }
      }
      String? validUsername;
      if (username != null) {
        if (await isUsernameAvailable(username) && isUsernameValid(username)) {
          validUsername = username;
        }
      }

      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;
      if (pic != null) updates['profile_picture'] = pic;
      if (validUsername != null) updates['username'] = validUsername;

      if (updates.isNotEmpty) {
        await supabase.from('users').update(updates).eq('id', state.user.uid);
      }
      if (validUsername != null) {
        state = state.copyWith(
          user: state.user.copyWith(username: validUsername),
        );
      }
    } catch (_) {
      state = state.copyWith(user: prev);
    }
  }

  Future<void> toggleShareOnlineStatus(bool selection) async {
    state = state.copyWith(
      user: state.user.copyWith(shareOnlineStatus: selection),
    );
    try {
      await supabase
          .from('users')
          .update({'share_online_status': selection}).eq('id', state.user.uid);
    } catch (e) {
      debugPrint('toggleShareOnlineStatus error: $e');
    }
  }

  Future<String?> _uploadProfilePicture(File img) async {
    final uid = state.user.uid;
    try {
      final bytes = await img.readAsBytes();
      final path = 'profile_pictures/$uid/profile.jpg';
      await supabase.storage.from('avatars').uploadBinary(path, bytes,
          fileOptions: const supabase_flutter.FileOptions(upsert: true));
      final url = supabase.storage.from('avatars').getPublicUrl(path);
      return url;
    } catch (_) {
      return null;
    }
  }

  // LIKES //
  void addIdToLiked(String id) {
    final likes = Set<String>.from(state.likedPosts);
    likes.add(id);
    state = state.copyWith(likedPosts: likes);
  }

  void removeIdFromLiked(String id) {
    final likes = Set<String>.from(state.likedPosts);
    likes.remove(id);
    state = state.copyWith(likedPosts: likes);
  }

  void addIdToDisliked(String id) {
    final dislikes = Set<String>.from(state.dislikedPosts);
    dislikes.add(id);
    state = state.copyWith(dislikedPosts: dislikes);
  }

  void removeIdFromDisliked(String id) {
    final dislikes = Set<String>.from(state.dislikedPosts);
    dislikes.remove(id);
    state = state.copyWith(dislikedPosts: dislikes);
  }

  // END LIKES //

  Future<void> signOut() async {
    await removeFCM(state.user.uid);
    await supabase.auth.signOut();
  }

  void addPollVote(String id, int optionIndex) {
    final votes = Map<String, int>.from(state.pollVotes);
    votes[id] = optionIndex;
    state = state.copyWith(pollVotes: votes);
  }

  void removePollVote(String id) {
    final votes = Map<String, int>.from(state.pollVotes);
    votes.remove(id);
    state = state.copyWith(pollVotes: votes);
  }

  Future<List<String>> _getPeopleWhoBlockedMe() async {
    try {
      final uid = ref.read(authProvider).uid!;
      final rows = await supabase
          .from('blocked')
          .select('source_uid')
          .eq('target_uid', uid);
      return (rows as List).map((r) => r['source_uid'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> blockUser(String uid) async {
    state = state.copyWith(blockedUsers: <String>{...state.blockedUsers, uid});
    try {
      await supabase.from('blocked').insert({
        'source_uid': state.user.uid,
        'target_uid': uid,
      });
    } catch (e) {
      final blocked = <String>{...state.blockedUsers};
      blocked.remove(uid);
      state = state.copyWith(blockedUsers: blocked);
    }
    removeFollower(uid);
  }

  Future<void> unBlockUser(String uid) async {
    final blocked = <String>{...state.blockedUsers};
    blocked.remove(uid);
    state = state.copyWith(blockedUsers: blocked);
    try {
      await supabase
          .from('blocked')
          .delete()
          .eq('source_uid', state.user.uid)
          .eq('target_uid', uid);
    } catch (e) {
      state = state.copyWith(
        blockedUsers: <String>{...state.blockedUsers, uid},
      );
    }
  }

  Future<void> reload() async {
    final uid = ref.read(authProvider).uid!;
    try {
      final response = await supabase.rpc(
        'get_user_by_id',
        params: {'p_uid': uid},
      );
      final row = Map<String, dynamic>.from(response.first);
      final blockedBy = await _getPeopleWhoBlockedMe();
      state = CurrentUserModel.fromJson(
        currentUserDocFromSupabaseRow(row, blockedBy),
      );
    } catch (e) {
      debugPrint('Error reloading current user from Supabase: $e');
    }
  }

  Future<void> addFollower(String otherUid) async {
    try {
      final updatedFollowing = [...state.user.following, otherUid];
      state = state.copyWith(
        user: state.user.copyWith(following: updatedFollowing),
      );
      final userState = ref.read(userProvider(otherUid));
      userState.whenData((otherUser) {
        if (!otherUser.followers.contains(state.user.uid)) {
          final updatedFollowers = [...otherUser.followers, state.user.uid];
          ref
              .read(userProvider(otherUid).notifier)
              .updateFollowers(updatedFollowers);
        }
      });

      final uid = state.user.uid;
      await supabase.from('following').insert({
        'source_uid': uid,
        'target_uid': otherUid,
      });
      await uploadActivity(
        ActivityModel(
          createdAt: DateTime.now().toUtc().toIso8601String(),
          id: '',
          content: 'Someone followed you',
          type: 'follow',
          path: uid,
        ),
        uid,
      );
    } catch (e) {
      final revertedFollowing =
          state.user.following.where((id) => id != otherUid).toList();
      state = state.copyWith(
        user: state.user.copyWith(following: revertedFollowing),
      );
      final userState = ref.read(userProvider(otherUid));
      userState.whenData((otherUser) {
        final revertedFollowers =
            otherUser.followers.where((id) => id != state.user.uid).toList();
        ref
            .read(userProvider(otherUid).notifier)
            .updateFollowers(revertedFollowers);
      });
    }
  }

  Future<void> removeFollower(String otherUid) async {
    try {
      final updatedFollowing =
          state.user.following.where((id) => id != otherUid).toList();
      state = state.copyWith(
        user: state.user.copyWith(following: updatedFollowing),
      );
      final userState = ref.read(userProvider(otherUid));
      userState.whenData((otherUser) {
        final updatedFollowers =
            otherUser.followers.where((id) => id != state.user.uid).toList();
        ref
            .read(userProvider(otherUid).notifier)
            .updateFollowers(updatedFollowers);
      });

      final uid = ref.read(authProvider).uid!;
      await supabase
          .from('following')
          .delete()
          .eq('source_uid', uid)
          .eq('target_uid', otherUid);
    } catch (e) {
      final revertedFollowing = [...state.user.following, otherUid];
      state = state.copyWith(
        user: state.user.copyWith(following: revertedFollowing),
      );
      final userState = ref.read(userProvider(otherUid));
      userState.whenData((otherUser) {
        if (!otherUser.followers.contains(state.user.uid)) {
          final revertedFollowers = [...otherUser.followers, state.user.uid];
          ref
              .read(userProvider(otherUid).notifier)
              .updateFollowers(revertedFollowers);
        }
      });
    }
  }
}
