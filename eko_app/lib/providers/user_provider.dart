import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/utilities/supabase_user_map.dart';

// Necessary for code-generation to work
part '../generated/providers/user_provider.g.dart';

@riverpod
class User extends _$User {
  Timer? _disposeTimer;
  @override
  FutureOr<UserModel> build(String uid) {
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

    if (ref.watch(authProvider).uid == uid) {
      return ref.watch(currentUserProvider).user;
    }

    final cacheValue = ref.read(userPoolProvider).getItem(uid);
    if (cacheValue != null) {
      return cacheValue;
    }
    return _fetchUserModel(uid);
  }

  Future<UserModel> _fetchUserModel(String uid) async {
    try {
      final response =
          await supabase.rpc('get_user_by_id', params: {'p_uid': uid});
      if (response is! List || response.isEmpty) return UserModel.userNotFound();
      final row = response.first;
      if (row is! Map) return UserModel.userNotFound();
      final doc = currentUserDocFromSupabaseRow(
        Map<String, dynamic>.from(row),
        const [],
      );
      return UserModel.fromJson(doc);
    } catch (_) {
      return UserModel.userNotFound();
    }
  }

  void updateFollowers(List<String> newFollowers) {
    // state.whenData((user) {
    //   state = AsyncData(user.copyWith(followers: newFollowers));
    // });
  }
}
