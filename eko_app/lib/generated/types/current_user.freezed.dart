// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/current_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrentUserModel {
  UserModel get user;
  Set<String> get blockedUsers;
  Set<String> get blockedBy;

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CurrentUserModelCopyWith<CurrentUserModel> get copyWith =>
      _$CurrentUserModelCopyWithImpl<CurrentUserModel>(
          this as CurrentUserModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CurrentUserModel &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality()
                .equals(other.blockedUsers, blockedUsers) &&
            const DeepCollectionEquality().equals(other.blockedBy, blockedBy));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      const DeepCollectionEquality().hash(blockedUsers),
      const DeepCollectionEquality().hash(blockedBy));

  @override
  String toString() {
    return 'CurrentUserModel(user: $user, blockedUsers: $blockedUsers, blockedBy: $blockedBy)';
  }
}

/// @nodoc
abstract mixin class $CurrentUserModelCopyWith<$Res> {
  factory $CurrentUserModelCopyWith(
          CurrentUserModel value, $Res Function(CurrentUserModel) _then) =
      _$CurrentUserModelCopyWithImpl;
  @useResult
  $Res call({UserModel user, Set<String> blockedUsers, Set<String> blockedBy});

  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class _$CurrentUserModelCopyWithImpl<$Res>
    implements $CurrentUserModelCopyWith<$Res> {
  _$CurrentUserModelCopyWithImpl(this._self, this._then);

  final CurrentUserModel _self;
  final $Res Function(CurrentUserModel) _then;

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? blockedUsers = null,
    Object? blockedBy = null,
  }) {
    return _then(_self.copyWith(
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
      blockedUsers: null == blockedUsers
          ? _self.blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      blockedBy: null == blockedBy
          ? _self.blockedBy
          : blockedBy // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

/// Adds pattern-matching-related methods to [CurrentUserModel].
extension CurrentUserModelPatterns on CurrentUserModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CurrentUserModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CurrentUserModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_CurrentUserModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CurrentUserModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CurrentUserModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CurrentUserModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            UserModel user, Set<String> blockedUsers, Set<String> blockedBy)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CurrentUserModel() when $default != null:
        return $default(_that.user, _that.blockedUsers, _that.blockedBy);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            UserModel user, Set<String> blockedUsers, Set<String> blockedBy)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CurrentUserModel():
        return $default(_that.user, _that.blockedUsers, _that.blockedBy);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            UserModel user, Set<String> blockedUsers, Set<String> blockedBy)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CurrentUserModel() when $default != null:
        return $default(_that.user, _that.blockedUsers, _that.blockedBy);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CurrentUserModel implements CurrentUserModel {
  const _CurrentUserModel(
      {required this.user,
      required final Set<String> blockedUsers,
      required final Set<String> blockedBy})
      : _blockedUsers = blockedUsers,
        _blockedBy = blockedBy;

  @override
  final UserModel user;
  final Set<String> _blockedUsers;
  @override
  Set<String> get blockedUsers {
    if (_blockedUsers is EqualUnmodifiableSetView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_blockedUsers);
  }

  final Set<String> _blockedBy;
  @override
  Set<String> get blockedBy {
    if (_blockedBy is EqualUnmodifiableSetView) return _blockedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_blockedBy);
  }

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CurrentUserModelCopyWith<_CurrentUserModel> get copyWith =>
      __$CurrentUserModelCopyWithImpl<_CurrentUserModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CurrentUserModel &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality()
                .equals(other._blockedUsers, _blockedUsers) &&
            const DeepCollectionEquality()
                .equals(other._blockedBy, _blockedBy));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      const DeepCollectionEquality().hash(_blockedUsers),
      const DeepCollectionEquality().hash(_blockedBy));

  @override
  String toString() {
    return 'CurrentUserModel(user: $user, blockedUsers: $blockedUsers, blockedBy: $blockedBy)';
  }
}

/// @nodoc
abstract mixin class _$CurrentUserModelCopyWith<$Res>
    implements $CurrentUserModelCopyWith<$Res> {
  factory _$CurrentUserModelCopyWith(
          _CurrentUserModel value, $Res Function(_CurrentUserModel) _then) =
      __$CurrentUserModelCopyWithImpl;
  @override
  @useResult
  $Res call({UserModel user, Set<String> blockedUsers, Set<String> blockedBy});

  @override
  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class __$CurrentUserModelCopyWithImpl<$Res>
    implements _$CurrentUserModelCopyWith<$Res> {
  __$CurrentUserModelCopyWithImpl(this._self, this._then);

  final _CurrentUserModel _self;
  final $Res Function(_CurrentUserModel) _then;

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? user = null,
    Object? blockedUsers = null,
    Object? blockedBy = null,
  }) {
    return _then(_CurrentUserModel(
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
      blockedUsers: null == blockedUsers
          ? _self._blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      blockedBy: null == blockedBy
          ? _self._blockedBy
          : blockedBy // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

// dart format on
