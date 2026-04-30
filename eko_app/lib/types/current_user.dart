import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:eko_app/types/user.dart';

part '../generated/types/current_user.freezed.dart';

@freezed
abstract class CurrentUserModel with _$CurrentUserModel {
  const factory CurrentUserModel({
    required UserModel user,
    required Set<String> likedPosts,
    required Set<String> dislikedPosts,
    required Set<String> blockedUsers,
    required Set<String> blockedBy,
  }) = _CurrentUserModel;
  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    Set<String> asSet(Object? value) {
      if (value is List) {
        return value.map((e) => '$e').toSet();
      }
      return <String>{};
    }

    final profileDataRaw = json['profileData'] ?? json['profile_data'];
    final profileData = profileDataRaw is Map
        ? Map<String, dynamic>.from(profileDataRaw)
        : <String, dynamic>{};

    return CurrentUserModel(
      user: UserModel.fromJson(json),
      likedPosts: asSet(
        profileData['likedPosts'] ??
            profileData['liked_posts'] ??
            json['likedPosts'] ??
            json['liked_posts'],
      ),
      dislikedPosts: asSet(
        profileData['dislikedPosts'] ??
            profileData['disliked_posts'] ??
            json['dislikedPosts'] ??
            json['disliked_posts'],
      ),
      blockedBy: asSet(json['blockedBy'] ?? json['blocked_by']),
      blockedUsers: asSet(json['blockedUsers'] ?? json['blocked_users']),
    );
  }

  // this is the initial state of the current user. It is only to make the current user not nullable
  factory CurrentUserModel.loading() {
    return CurrentUserModel(
      user: UserModel.userNotFound(),
      dislikedPosts: {},
      likedPosts: {},
      blockedUsers: {},
      blockedBy: {},
    );
  }
}
