// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupModel implements DiagnosticableTreeMixin {
  String get id;
  String get name;
  String get description;
  String get lastActivity;
  String get createdOn;
  String get icon;
  List<String> get members;
  List<String> get notSeen;

  /// Create a copy of GroupModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GroupModelCopyWith<GroupModel> get copyWith =>
      _$GroupModelCopyWithImpl<GroupModel>(this as GroupModel, _$identity);

  /// Serializes this GroupModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GroupModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('lastActivity', lastActivity))
      ..add(DiagnosticsProperty('createdOn', createdOn))
      ..add(DiagnosticsProperty('icon', icon))
      ..add(DiagnosticsProperty('members', members))
      ..add(DiagnosticsProperty('notSeen', notSeen));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GroupModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity) &&
            (identical(other.createdOn, createdOn) ||
                other.createdOn == createdOn) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            const DeepCollectionEquality().equals(other.members, members) &&
            const DeepCollectionEquality().equals(other.notSeen, notSeen));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      lastActivity,
      createdOn,
      icon,
      const DeepCollectionEquality().hash(members),
      const DeepCollectionEquality().hash(notSeen));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GroupModel(id: $id, name: $name, description: $description, lastActivity: $lastActivity, createdOn: $createdOn, icon: $icon, members: $members, notSeen: $notSeen)';
  }
}

/// @nodoc
abstract mixin class $GroupModelCopyWith<$Res> {
  factory $GroupModelCopyWith(
          GroupModel value, $Res Function(GroupModel) _then) =
      _$GroupModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String lastActivity,
      String createdOn,
      String icon,
      List<String> members,
      List<String> notSeen});
}

/// @nodoc
class _$GroupModelCopyWithImpl<$Res> implements $GroupModelCopyWith<$Res> {
  _$GroupModelCopyWithImpl(this._self, this._then);

  final GroupModel _self;
  final $Res Function(GroupModel) _then;

  /// Create a copy of GroupModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? lastActivity = null,
    Object? createdOn = null,
    Object? icon = null,
    Object? members = null,
    Object? notSeen = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      lastActivity: null == lastActivity
          ? _self.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as String,
      createdOn: null == createdOn
          ? _self.createdOn
          : createdOn // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      members: null == members
          ? _self.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notSeen: null == notSeen
          ? _self.notSeen
          : notSeen // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [GroupModel].
extension GroupModelPatterns on GroupModel {
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
    TResult Function(_GroupModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupModel() when $default != null:
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
    TResult Function(_GroupModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupModel():
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
    TResult? Function(_GroupModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupModel() when $default != null:
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
            String id,
            String name,
            String description,
            String lastActivity,
            String createdOn,
            String icon,
            List<String> members,
            List<String> notSeen)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupModel() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.lastActivity,
            _that.createdOn,
            _that.icon,
            _that.members,
            _that.notSeen);
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
            String id,
            String name,
            String description,
            String lastActivity,
            String createdOn,
            String icon,
            List<String> members,
            List<String> notSeen)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupModel():
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.lastActivity,
            _that.createdOn,
            _that.icon,
            _that.members,
            _that.notSeen);
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
            String id,
            String name,
            String description,
            String lastActivity,
            String createdOn,
            String icon,
            List<String> members,
            List<String> notSeen)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupModel() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.lastActivity,
            _that.createdOn,
            _that.icon,
            _that.members,
            _that.notSeen);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GroupModel extends GroupModel with DiagnosticableTreeMixin {
  const _GroupModel(
      {this.id = '',
      required this.name,
      required this.description,
      required this.lastActivity,
      required this.createdOn,
      required this.icon,
      required final List<String> members,
      final List<String> notSeen = const []})
      : _members = members,
        _notSeen = notSeen,
        super._();
  factory _GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String lastActivity;
  @override
  final String createdOn;
  @override
  final String icon;
  final List<String> _members;
  @override
  List<String> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  final List<String> _notSeen;
  @override
  @JsonKey()
  List<String> get notSeen {
    if (_notSeen is EqualUnmodifiableListView) return _notSeen;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notSeen);
  }

  /// Create a copy of GroupModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GroupModelCopyWith<_GroupModel> get copyWith =>
      __$GroupModelCopyWithImpl<_GroupModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GroupModelToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GroupModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('lastActivity', lastActivity))
      ..add(DiagnosticsProperty('createdOn', createdOn))
      ..add(DiagnosticsProperty('icon', icon))
      ..add(DiagnosticsProperty('members', members))
      ..add(DiagnosticsProperty('notSeen', notSeen));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GroupModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity) &&
            (identical(other.createdOn, createdOn) ||
                other.createdOn == createdOn) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            const DeepCollectionEquality().equals(other._notSeen, _notSeen));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      lastActivity,
      createdOn,
      icon,
      const DeepCollectionEquality().hash(_members),
      const DeepCollectionEquality().hash(_notSeen));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GroupModel(id: $id, name: $name, description: $description, lastActivity: $lastActivity, createdOn: $createdOn, icon: $icon, members: $members, notSeen: $notSeen)';
  }
}

/// @nodoc
abstract mixin class _$GroupModelCopyWith<$Res>
    implements $GroupModelCopyWith<$Res> {
  factory _$GroupModelCopyWith(
          _GroupModel value, $Res Function(_GroupModel) _then) =
      __$GroupModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String lastActivity,
      String createdOn,
      String icon,
      List<String> members,
      List<String> notSeen});
}

/// @nodoc
class __$GroupModelCopyWithImpl<$Res> implements _$GroupModelCopyWith<$Res> {
  __$GroupModelCopyWithImpl(this._self, this._then);

  final _GroupModel _self;
  final $Res Function(_GroupModel) _then;

  /// Create a copy of GroupModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? lastActivity = null,
    Object? createdOn = null,
    Object? icon = null,
    Object? members = null,
    Object? notSeen = null,
  }) {
    return _then(_GroupModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      lastActivity: null == lastActivity
          ? _self.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as String,
      createdOn: null == createdOn
          ? _self.createdOn
          : createdOn // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      members: null == members
          ? _self._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notSeen: null == notSeen
          ? _self._notSeen
          : notSeen // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
