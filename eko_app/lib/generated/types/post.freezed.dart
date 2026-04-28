// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostModel implements DiagnosticableTreeMixin {
  @JsonKey(name: 'author')
  String get uid;
  int get id;
  String? get gifUrl;
  @JsonKey(
      name: 'image',
      fromJson: _asciiImageFromString,
      toJson: _asciiImageToString)
  AsciiImage? get imageString;
  @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
  List<String> get title;
  @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
  List<String> get body;
  List<String> get tags;
  int get likes;
  int get dislikes;
  int get commentCount;
  bool get isLiked;
  bool get isDisliked;
  @JsonKey(name: 'time')
  String get createdAt;
  List<String>? get pollOptions;
  Map<String, int>? get pollVoteCounts;
  int? get repostId;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PostModelCopyWith<PostModel> get copyWith =>
      _$PostModelCopyWithImpl<PostModel>(this as PostModel, _$identity);

  /// Serializes this PostModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostModel'))
      ..add(DiagnosticsProperty('uid', uid))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('gifUrl', gifUrl))
      ..add(DiagnosticsProperty('imageString', imageString))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('body', body))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('likes', likes))
      ..add(DiagnosticsProperty('dislikes', dislikes))
      ..add(DiagnosticsProperty('commentCount', commentCount))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('isDisliked', isDisliked))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('pollOptions', pollOptions))
      ..add(DiagnosticsProperty('pollVoteCounts', pollVoteCounts))
      ..add(DiagnosticsProperty('repostId', repostId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PostModel &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl) &&
            (identical(other.imageString, imageString) ||
                other.imageString == imageString) &&
            const DeepCollectionEquality().equals(other.title, title) &&
            const DeepCollectionEquality().equals(other.body, body) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.dislikes, dislikes) ||
                other.dislikes == dislikes) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other.pollOptions, pollOptions) &&
            const DeepCollectionEquality()
                .equals(other.pollVoteCounts, pollVoteCounts) &&
            (identical(other.repostId, repostId) ||
                other.repostId == repostId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      id,
      gifUrl,
      imageString,
      const DeepCollectionEquality().hash(title),
      const DeepCollectionEquality().hash(body),
      const DeepCollectionEquality().hash(tags),
      likes,
      dislikes,
      commentCount,
      isLiked,
      isDisliked,
      createdAt,
      const DeepCollectionEquality().hash(pollOptions),
      const DeepCollectionEquality().hash(pollVoteCounts),
      repostId);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostModel(uid: $uid, id: $id, gifUrl: $gifUrl, imageString: $imageString, title: $title, body: $body, tags: $tags, likes: $likes, dislikes: $dislikes, commentCount: $commentCount, isLiked: $isLiked, isDisliked: $isDisliked, createdAt: $createdAt, pollOptions: $pollOptions, pollVoteCounts: $pollVoteCounts, repostId: $repostId)';
  }
}

/// @nodoc
abstract mixin class $PostModelCopyWith<$Res> {
  factory $PostModelCopyWith(PostModel value, $Res Function(PostModel) _then) =
      _$PostModelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'author') String uid,
      int id,
      String? gifUrl,
      @JsonKey(
          name: 'image',
          fromJson: _asciiImageFromString,
          toJson: _asciiImageToString)
      AsciiImage? imageString,
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList) List<String> title,
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList) List<String> body,
      List<String> tags,
      int likes,
      int dislikes,
      int commentCount,
      bool isLiked,
      bool isDisliked,
      @JsonKey(name: 'time') String createdAt,
      List<String>? pollOptions,
      Map<String, int>? pollVoteCounts,
      int? repostId});
}

/// @nodoc
class _$PostModelCopyWithImpl<$Res> implements $PostModelCopyWith<$Res> {
  _$PostModelCopyWithImpl(this._self, this._then);

  final PostModel _self;
  final $Res Function(PostModel) _then;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? id = null,
    Object? gifUrl = freezed,
    Object? imageString = freezed,
    Object? title = null,
    Object? body = null,
    Object? tags = null,
    Object? likes = null,
    Object? dislikes = null,
    Object? commentCount = null,
    Object? isLiked = null,
    Object? isDisliked = null,
    Object? createdAt = null,
    Object? pollOptions = freezed,
    Object? pollVoteCounts = freezed,
    Object? repostId = freezed,
  }) {
    return _then(_self.copyWith(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      gifUrl: freezed == gifUrl
          ? _self.gifUrl
          : gifUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageString: freezed == imageString
          ? _self.imageString
          : imageString // ignore: cast_nullable_to_non_nullable
              as AsciiImage?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as List<String>,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likes: null == likes
          ? _self.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      dislikes: null == dislikes
          ? _self.dislikes
          : dislikes // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _self.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisliked: null == isDisliked
          ? _self.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      pollOptions: freezed == pollOptions
          ? _self.pollOptions
          : pollOptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      pollVoteCounts: freezed == pollVoteCounts
          ? _self.pollVoteCounts
          : pollVoteCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      repostId: freezed == repostId
          ? _self.repostId
          : repostId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PostModel].
extension PostModelPatterns on PostModel {
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
    TResult Function(_PostModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostModel() when $default != null:
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
    TResult Function(_PostModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostModel():
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
    TResult? Function(_PostModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostModel() when $default != null:
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
            @JsonKey(name: 'author') String uid,
            int id,
            String? gifUrl,
            @JsonKey(
                name: 'image',
                fromJson: _asciiImageFromString,
                toJson: _asciiImageToString)
            AsciiImage? imageString,
            @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
            List<String> title,
            @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
            List<String> body,
            List<String> tags,
            int likes,
            int dislikes,
            int commentCount,
            bool isLiked,
            bool isDisliked,
            @JsonKey(name: 'time') String createdAt,
            List<String>? pollOptions,
            Map<String, int>? pollVoteCounts,
            int? repostId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostModel() when $default != null:
        return $default(
            _that.uid,
            _that.id,
            _that.gifUrl,
            _that.imageString,
            _that.title,
            _that.body,
            _that.tags,
            _that.likes,
            _that.dislikes,
            _that.commentCount,
            _that.isLiked,
            _that.isDisliked,
            _that.createdAt,
            _that.pollOptions,
            _that.pollVoteCounts,
            _that.repostId);
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
            @JsonKey(name: 'author') String uid,
            int id,
            String? gifUrl,
            @JsonKey(
                name: 'image',
                fromJson: _asciiImageFromString,
                toJson: _asciiImageToString)
            AsciiImage? imageString,
            @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
            List<String> title,
            @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
            List<String> body,
            List<String> tags,
            int likes,
            int dislikes,
            int commentCount,
            bool isLiked,
            bool isDisliked,
            @JsonKey(name: 'time') String createdAt,
            List<String>? pollOptions,
            Map<String, int>? pollVoteCounts,
            int? repostId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostModel():
        return $default(
            _that.uid,
            _that.id,
            _that.gifUrl,
            _that.imageString,
            _that.title,
            _that.body,
            _that.tags,
            _that.likes,
            _that.dislikes,
            _that.commentCount,
            _that.isLiked,
            _that.isDisliked,
            _that.createdAt,
            _that.pollOptions,
            _that.pollVoteCounts,
            _that.repostId);
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
            @JsonKey(name: 'author') String uid,
            int id,
            String? gifUrl,
            @JsonKey(
                name: 'image',
                fromJson: _asciiImageFromString,
                toJson: _asciiImageToString)
            AsciiImage? imageString,
            @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
            List<String> title,
            @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
            List<String> body,
            List<String> tags,
            int likes,
            int dislikes,
            int commentCount,
            bool isLiked,
            bool isDisliked,
            @JsonKey(name: 'time') String createdAt,
            List<String>? pollOptions,
            Map<String, int>? pollVoteCounts,
            int? repostId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostModel() when $default != null:
        return $default(
            _that.uid,
            _that.id,
            _that.gifUrl,
            _that.imageString,
            _that.title,
            _that.body,
            _that.tags,
            _that.likes,
            _that.dislikes,
            _that.commentCount,
            _that.isLiked,
            _that.isDisliked,
            _that.createdAt,
            _that.pollOptions,
            _that.pollVoteCounts,
            _that.repostId);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PostModel extends PostModel with DiagnosticableTreeMixin {
  const _PostModel(
      {@JsonKey(name: 'author') required this.uid,
      required this.id,
      this.gifUrl,
      @JsonKey(
          name: 'image',
          fromJson: _asciiImageFromString,
          toJson: _asciiImageToString)
      this.imageString,
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
      final List<String> title = const <String>[],
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
      final List<String> body = const <String>[],
      final List<String> tags = const ['public'],
      this.likes = 0,
      this.dislikes = 0,
      this.commentCount = 0,
      this.isLiked = false,
      this.isDisliked = false,
      @JsonKey(name: 'time') required this.createdAt,
      final List<String>? pollOptions,
      final Map<String, int>? pollVoteCounts,
      this.repostId})
      : _title = title,
        _body = body,
        _tags = tags,
        _pollOptions = pollOptions,
        _pollVoteCounts = pollVoteCounts,
        super._();
  factory _PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  @override
  @JsonKey(name: 'author')
  final String uid;
  @override
  final int id;
  @override
  final String? gifUrl;
  @override
  @JsonKey(
      name: 'image',
      fromJson: _asciiImageFromString,
      toJson: _asciiImageToString)
  final AsciiImage? imageString;
  final List<String> _title;
  @override
  @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
  List<String> get title {
    if (_title is EqualUnmodifiableListView) return _title;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_title);
  }

  final List<String> _body;
  @override
  @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
  List<String> get body {
    if (_body is EqualUnmodifiableListView) return _body;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_body);
  }

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
  final int likes;
  @override
  @JsonKey()
  final int dislikes;
  @override
  @JsonKey()
  final int commentCount;
  @override
  @JsonKey()
  final bool isLiked;
  @override
  @JsonKey()
  final bool isDisliked;
  @override
  @JsonKey(name: 'time')
  final String createdAt;
  final List<String>? _pollOptions;
  @override
  List<String>? get pollOptions {
    final value = _pollOptions;
    if (value == null) return null;
    if (_pollOptions is EqualUnmodifiableListView) return _pollOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, int>? _pollVoteCounts;
  @override
  Map<String, int>? get pollVoteCounts {
    final value = _pollVoteCounts;
    if (value == null) return null;
    if (_pollVoteCounts is EqualUnmodifiableMapView) return _pollVoteCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final int? repostId;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PostModelCopyWith<_PostModel> get copyWith =>
      __$PostModelCopyWithImpl<_PostModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PostModelToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostModel'))
      ..add(DiagnosticsProperty('uid', uid))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('gifUrl', gifUrl))
      ..add(DiagnosticsProperty('imageString', imageString))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('body', body))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('likes', likes))
      ..add(DiagnosticsProperty('dislikes', dislikes))
      ..add(DiagnosticsProperty('commentCount', commentCount))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('isDisliked', isDisliked))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('pollOptions', pollOptions))
      ..add(DiagnosticsProperty('pollVoteCounts', pollVoteCounts))
      ..add(DiagnosticsProperty('repostId', repostId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PostModel &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl) &&
            (identical(other.imageString, imageString) ||
                other.imageString == imageString) &&
            const DeepCollectionEquality().equals(other._title, _title) &&
            const DeepCollectionEquality().equals(other._body, _body) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.dislikes, dislikes) ||
                other.dislikes == dislikes) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._pollOptions, _pollOptions) &&
            const DeepCollectionEquality()
                .equals(other._pollVoteCounts, _pollVoteCounts) &&
            (identical(other.repostId, repostId) ||
                other.repostId == repostId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      id,
      gifUrl,
      imageString,
      const DeepCollectionEquality().hash(_title),
      const DeepCollectionEquality().hash(_body),
      const DeepCollectionEquality().hash(_tags),
      likes,
      dislikes,
      commentCount,
      isLiked,
      isDisliked,
      createdAt,
      const DeepCollectionEquality().hash(_pollOptions),
      const DeepCollectionEquality().hash(_pollVoteCounts),
      repostId);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostModel(uid: $uid, id: $id, gifUrl: $gifUrl, imageString: $imageString, title: $title, body: $body, tags: $tags, likes: $likes, dislikes: $dislikes, commentCount: $commentCount, isLiked: $isLiked, isDisliked: $isDisliked, createdAt: $createdAt, pollOptions: $pollOptions, pollVoteCounts: $pollVoteCounts, repostId: $repostId)';
  }
}

/// @nodoc
abstract mixin class _$PostModelCopyWith<$Res>
    implements $PostModelCopyWith<$Res> {
  factory _$PostModelCopyWith(
          _PostModel value, $Res Function(_PostModel) _then) =
      __$PostModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'author') String uid,
      int id,
      String? gifUrl,
      @JsonKey(
          name: 'image',
          fromJson: _asciiImageFromString,
          toJson: _asciiImageToString)
      AsciiImage? imageString,
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList) List<String> title,
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList) List<String> body,
      List<String> tags,
      int likes,
      int dislikes,
      int commentCount,
      bool isLiked,
      bool isDisliked,
      @JsonKey(name: 'time') String createdAt,
      List<String>? pollOptions,
      Map<String, int>? pollVoteCounts,
      int? repostId});
}

/// @nodoc
class __$PostModelCopyWithImpl<$Res> implements _$PostModelCopyWith<$Res> {
  __$PostModelCopyWithImpl(this._self, this._then);

  final _PostModel _self;
  final $Res Function(_PostModel) _then;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? uid = null,
    Object? id = null,
    Object? gifUrl = freezed,
    Object? imageString = freezed,
    Object? title = null,
    Object? body = null,
    Object? tags = null,
    Object? likes = null,
    Object? dislikes = null,
    Object? commentCount = null,
    Object? isLiked = null,
    Object? isDisliked = null,
    Object? createdAt = null,
    Object? pollOptions = freezed,
    Object? pollVoteCounts = freezed,
    Object? repostId = freezed,
  }) {
    return _then(_PostModel(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      gifUrl: freezed == gifUrl
          ? _self.gifUrl
          : gifUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageString: freezed == imageString
          ? _self.imageString
          : imageString // ignore: cast_nullable_to_non_nullable
              as AsciiImage?,
      title: null == title
          ? _self._title
          : title // ignore: cast_nullable_to_non_nullable
              as List<String>,
      body: null == body
          ? _self._body
          : body // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likes: null == likes
          ? _self.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      dislikes: null == dislikes
          ? _self.dislikes
          : dislikes // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _self.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisliked: null == isDisliked
          ? _self.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      pollOptions: freezed == pollOptions
          ? _self._pollOptions
          : pollOptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      pollVoteCounts: freezed == pollVoteCounts
          ? _self._pollVoteCounts
          : pollVoteCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      repostId: freezed == repostId
          ? _self.repostId
          : repostId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
