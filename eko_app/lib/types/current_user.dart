import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:eko_app/types/user.dart';

part '../generated/types/current_user.freezed.dart';

@freezed
abstract class CurrentUserModel with _$CurrentUserModel {
  const factory CurrentUserModel({
    required UserModel user,
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

    return CurrentUserModel(
      user: UserModel.fromJson(json),
      blockedBy: asSet(json['blockedBy'] ?? json['blocked_by']),
      blockedUsers: asSet(json['blockedUsers'] ?? json['blocked_users']),
    );
  }

  // this is the initial state of the current user. It is only to make the current user not nullable
  factory CurrentUserModel.loading() {
    return CurrentUserModel(
      user: UserModel.userNotFound(),
      blockedUsers: {},
      blockedBy: {},
    );
  }
}
