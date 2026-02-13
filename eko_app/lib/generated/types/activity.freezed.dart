// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivityModel implements DiagnosticableTreeMixin {
  String? get sourceUid;
  String get id;
  @JsonKey(name: 'time')
  String get createdAt;
  List<String> get tags;
  String get type;
  String get content;
  String get path;

  /// Create a copy of ActivityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActivityModelCopyWith<ActivityModel> get copyWith =>
      _$ActivityModelCopyWithImpl<ActivityModel>(
          this as ActivityModel, _$identity);

  /// Serializes this ActivityModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ActivityModel'))
      ..add(DiagnosticsProperty('sourceUid', sourceUid))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('path', path));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActivityModel &&
            (identical(other.sourceUid, sourceUid) ||
                other.sourceUid == sourceUid) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.path, path) || other.path == path));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sourceUid, id, createdAt,
      const DeepCollectionEquality().hash(tags), type, content, path);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ActivityModel(sourceUid: $sourceUid, id: $id, createdAt: $createdAt, tags: $tags, type: $type, content: $content, path: $path)';
  }
}

/// @nodoc
abstract mixin class $ActivityModelCopyWith<$Res> {
  factory $ActivityModelCopyWith(
          ActivityModel value, $Res Function(ActivityModel) _then) =
      _$ActivityModelCopyWithImpl;
  @useResult
  $Res call(
      {String? sourceUid,
      String id,
      @JsonKey(name: 'time') String createdAt,
      List<String> tags,
      String type,
      String content,
      String path});
}

/// @nodoc
class _$ActivityModelCopyWithImpl<$Res>
    implements $ActivityModelCopyWith<$Res> {
  _$ActivityModelCopyWithImpl(this._self, this._then);

  final ActivityModel _self;
  final $Res Function(ActivityModel) _then;

  /// Create a copy of ActivityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceUid = freezed,
    Object? id = null,
    Object? createdAt = null,
    Object? tags = null,
    Object? type = null,
    Object? content = null,
    Object? path = null,
  }) {
    return _then(_self.copyWith(
      sourceUid: freezed == sourceUid
          ? _self.sourceUid
          : sourceUid // ignore: cast_nullable_to_non_nullable
              as String?,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ActivityModel].
extension ActivityModelPatterns on ActivityModel {
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
    TResult Function(_ActivityModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActivityModel() when $default != null:
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
    TResult Function(_ActivityModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityModel():
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
    TResult? Function(_ActivityModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityModel() when $default != null:
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
            String? sourceUid,
            String id,
            @JsonKey(name: 'time') String createdAt,
            List<String> tags,
            String type,
            String content,
            String path)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActivityModel() when $default != null:
        return $default(_that.sourceUid, _that.id, _that.createdAt, _that.tags,
            _that.type, _that.content, _that.path);
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
            String? sourceUid,
            String id,
            @JsonKey(name: 'time') String createdAt,
            List<String> tags,
            String type,
            String content,
            String path)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityModel():
        return $default(_that.sourceUid, _that.id, _that.createdAt, _that.tags,
            _that.type, _that.content, _that.path);
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
            String? sourceUid,
            String id,
            @JsonKey(name: 'time') String createdAt,
            List<String> tags,
            String type,
            String content,
            String path)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityModel() when $default != null:
        return $default(_that.sourceUid, _that.id, _that.createdAt, _that.tags,
            _that.type, _that.content, _that.path);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ActivityModel extends ActivityModel with DiagnosticableTreeMixin {
  const _ActivityModel(
      {this.sourceUid = null,
      required this.id,
      @JsonKey(name: 'time') required this.createdAt,
      final List<String> tags = const <String>[],
      this.type = '',
      this.content = '',
      this.path = ''})
      : _tags = tags,
        super._();
  factory _ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  @override
  @JsonKey()
  final String? sourceUid;
  @override
  final String id;
  @override
  @JsonKey(name: 'time')
  final String createdAt;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String content;
  @override
  @JsonKey()
  final String path;

  /// Create a copy of ActivityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActivityModelCopyWith<_ActivityModel> get copyWith =>
      __$ActivityModelCopyWithImpl<_ActivityModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ActivityModelToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ActivityModel'))
      ..add(DiagnosticsProperty('sourceUid', sourceUid))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('path', path));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ActivityModel &&
            (identical(other.sourceUid, sourceUid) ||
                other.sourceUid == sourceUid) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.path, path) || other.path == path));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sourceUid, id, createdAt,
      const DeepCollectionEquality().hash(_tags), type, content, path);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ActivityModel(sourceUid: $sourceUid, id: $id, createdAt: $createdAt, tags: $tags, type: $type, content: $content, path: $path)';
  }
}

/// @nodoc
abstract mixin class _$ActivityModelCopyWith<$Res>
    implements $ActivityModelCopyWith<$Res> {
  factory _$ActivityModelCopyWith(
          _ActivityModel value, $Res Function(_ActivityModel) _then) =
      __$ActivityModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? sourceUid,
      String id,
      @JsonKey(name: 'time') String createdAt,
      List<String> tags,
      String type,
      String content,
      String path});
}

/// @nodoc
class __$ActivityModelCopyWithImpl<$Res>
    implements _$ActivityModelCopyWith<$Res> {
  __$ActivityModelCopyWithImpl(this._self, this._then);

  final _ActivityModel _self;
  final $Res Function(_ActivityModel) _then;

  /// Create a copy of ActivityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sourceUid = freezed,
    Object? id = null,
    Object? createdAt = null,
    Object? tags = null,
    Object? type = null,
    Object? content = null,
    Object? path = null,
  }) {
    return _then(_ActivityModel(
      sourceUid: freezed == sourceUid
          ? _self.sourceUid
          : sourceUid // ignore: cast_nullable_to_non_nullable
              as String?,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
