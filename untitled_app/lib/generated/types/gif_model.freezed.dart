// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/gif_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KlipyResponse {
  List<KlipyResult> get results;

  /// Create a copy of KlipyResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $KlipyResponseCopyWith<KlipyResponse> get copyWith =>
      _$KlipyResponseCopyWithImpl<KlipyResponse>(
          this as KlipyResponse, _$identity);

  /// Serializes this KlipyResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is KlipyResponse &&
            const DeepCollectionEquality().equals(other.results, results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(results));

  @override
  String toString() {
    return 'KlipyResponse(results: $results)';
  }
}

/// @nodoc
abstract mixin class $KlipyResponseCopyWith<$Res> {
  factory $KlipyResponseCopyWith(
          KlipyResponse value, $Res Function(KlipyResponse) _then) =
      _$KlipyResponseCopyWithImpl;
  @useResult
  $Res call({List<KlipyResult> results});
}

/// @nodoc
class _$KlipyResponseCopyWithImpl<$Res>
    implements $KlipyResponseCopyWith<$Res> {
  _$KlipyResponseCopyWithImpl(this._self, this._then);

  final KlipyResponse _self;
  final $Res Function(KlipyResponse) _then;

  /// Create a copy of KlipyResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? results = null,
  }) {
    return _then(_self.copyWith(
      results: null == results
          ? _self.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<KlipyResult>,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _KlipyResponse implements KlipyResponse {
  const _KlipyResponse({required final List<KlipyResult> results})
      : _results = results;
  factory _KlipyResponse.fromJson(Map<String, dynamic> json) =>
      _$KlipyResponseFromJson(json);

  final List<KlipyResult> _results;
  @override
  List<KlipyResult> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  /// Create a copy of KlipyResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$KlipyResponseCopyWith<_KlipyResponse> get copyWith =>
      __$KlipyResponseCopyWithImpl<_KlipyResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$KlipyResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _KlipyResponse &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_results));

  @override
  String toString() {
    return 'KlipyResponse(results: $results)';
  }
}

/// @nodoc
abstract mixin class _$KlipyResponseCopyWith<$Res>
    implements $KlipyResponseCopyWith<$Res> {
  factory _$KlipyResponseCopyWith(
          _KlipyResponse value, $Res Function(_KlipyResponse) _then) =
      __$KlipyResponseCopyWithImpl;
  @override
  @useResult
  $Res call({List<KlipyResult> results});
}

/// @nodoc
class __$KlipyResponseCopyWithImpl<$Res>
    implements _$KlipyResponseCopyWith<$Res> {
  __$KlipyResponseCopyWithImpl(this._self, this._then);

  final _KlipyResponse _self;
  final $Res Function(_KlipyResponse) _then;

  /// Create a copy of KlipyResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? results = null,
  }) {
    return _then(_KlipyResponse(
      results: null == results
          ? _self._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<KlipyResult>,
    ));
  }
}

/// @nodoc
mixin _$KlipyResult {
  String get id;
  String get title;
  @JsonKey(name: 'media_formats')
  MediaFormats get mediaFormats;
  @JsonKey(name: 'content_description')
  String? get contentDescription;
  String get itemurl;
  String get url;
  List<String> get tags;

  /// Create a copy of KlipyResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $KlipyResultCopyWith<KlipyResult> get copyWith =>
      _$KlipyResultCopyWithImpl<KlipyResult>(this as KlipyResult, _$identity);

  /// Serializes this KlipyResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is KlipyResult &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.mediaFormats, mediaFormats) ||
                other.mediaFormats == mediaFormats) &&
            (identical(other.contentDescription, contentDescription) ||
                other.contentDescription == contentDescription) &&
            (identical(other.itemurl, itemurl) || other.itemurl == itemurl) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other.tags, tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      mediaFormats,
      contentDescription,
      itemurl,
      url,
      const DeepCollectionEquality().hash(tags));

  @override
  String toString() {
    return 'KlipyResult(id: $id, title: $title, mediaFormats: $mediaFormats, contentDescription: $contentDescription, itemurl: $itemurl, url: $url, tags: $tags)';
  }
}

/// @nodoc
abstract mixin class $KlipyResultCopyWith<$Res> {
  factory $KlipyResultCopyWith(
          KlipyResult value, $Res Function(KlipyResult) _then) =
      _$KlipyResultCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'media_formats') MediaFormats mediaFormats,
      @JsonKey(name: 'content_description') String? contentDescription,
      String itemurl,
      String url,
      List<String> tags});

  $MediaFormatsCopyWith<$Res> get mediaFormats;
}

/// @nodoc
class _$KlipyResultCopyWithImpl<$Res> implements $KlipyResultCopyWith<$Res> {
  _$KlipyResultCopyWithImpl(this._self, this._then);

  final KlipyResult _self;
  final $Res Function(KlipyResult) _then;

  /// Create a copy of KlipyResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? mediaFormats = null,
    Object? contentDescription = freezed,
    Object? itemurl = null,
    Object? url = null,
    Object? tags = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      mediaFormats: null == mediaFormats
          ? _self.mediaFormats
          : mediaFormats // ignore: cast_nullable_to_non_nullable
              as MediaFormats,
      contentDescription: freezed == contentDescription
          ? _self.contentDescription
          : contentDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      itemurl: null == itemurl
          ? _self.itemurl
          : itemurl // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }

  /// Create a copy of KlipyResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaFormatsCopyWith<$Res> get mediaFormats {
    return $MediaFormatsCopyWith<$Res>(_self.mediaFormats, (value) {
      return _then(_self.copyWith(mediaFormats: value));
    });
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _KlipyResult implements KlipyResult {
  const _KlipyResult(
      {required this.id,
      required this.title,
      @JsonKey(name: 'media_formats') required this.mediaFormats,
      @JsonKey(name: 'content_description') this.contentDescription,
      required this.itemurl,
      required this.url,
      required final List<String> tags})
      : _tags = tags;
  factory _KlipyResult.fromJson(Map<String, dynamic> json) =>
      _$KlipyResultFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey(name: 'media_formats')
  final MediaFormats mediaFormats;
  @override
  @JsonKey(name: 'content_description')
  final String? contentDescription;
  @override
  final String itemurl;
  @override
  final String url;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Create a copy of KlipyResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$KlipyResultCopyWith<_KlipyResult> get copyWith =>
      __$KlipyResultCopyWithImpl<_KlipyResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$KlipyResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _KlipyResult &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.mediaFormats, mediaFormats) ||
                other.mediaFormats == mediaFormats) &&
            (identical(other.contentDescription, contentDescription) ||
                other.contentDescription == contentDescription) &&
            (identical(other.itemurl, itemurl) || other.itemurl == itemurl) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      mediaFormats,
      contentDescription,
      itemurl,
      url,
      const DeepCollectionEquality().hash(_tags));

  @override
  String toString() {
    return 'KlipyResult(id: $id, title: $title, mediaFormats: $mediaFormats, contentDescription: $contentDescription, itemurl: $itemurl, url: $url, tags: $tags)';
  }
}

/// @nodoc
abstract mixin class _$KlipyResultCopyWith<$Res>
    implements $KlipyResultCopyWith<$Res> {
  factory _$KlipyResultCopyWith(
          _KlipyResult value, $Res Function(_KlipyResult) _then) =
      __$KlipyResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'media_formats') MediaFormats mediaFormats,
      @JsonKey(name: 'content_description') String? contentDescription,
      String itemurl,
      String url,
      List<String> tags});

  @override
  $MediaFormatsCopyWith<$Res> get mediaFormats;
}

/// @nodoc
class __$KlipyResultCopyWithImpl<$Res> implements _$KlipyResultCopyWith<$Res> {
  __$KlipyResultCopyWithImpl(this._self, this._then);

  final _KlipyResult _self;
  final $Res Function(_KlipyResult) _then;

  /// Create a copy of KlipyResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? mediaFormats = null,
    Object? contentDescription = freezed,
    Object? itemurl = null,
    Object? url = null,
    Object? tags = null,
  }) {
    return _then(_KlipyResult(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      mediaFormats: null == mediaFormats
          ? _self.mediaFormats
          : mediaFormats // ignore: cast_nullable_to_non_nullable
              as MediaFormats,
      contentDescription: freezed == contentDescription
          ? _self.contentDescription
          : contentDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      itemurl: null == itemurl
          ? _self.itemurl
          : itemurl // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }

  /// Create a copy of KlipyResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaFormatsCopyWith<$Res> get mediaFormats {
    return $MediaFormatsCopyWith<$Res>(_self.mediaFormats, (value) {
      return _then(_self.copyWith(mediaFormats: value));
    });
  }
}

/// @nodoc
mixin _$MediaFormats {
  GifFormat get gif;

  /// Create a copy of MediaFormats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MediaFormatsCopyWith<MediaFormats> get copyWith =>
      _$MediaFormatsCopyWithImpl<MediaFormats>(
          this as MediaFormats, _$identity);

  /// Serializes this MediaFormats to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MediaFormats &&
            (identical(other.gif, gif) || other.gif == gif));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gif);

  @override
  String toString() {
    return 'MediaFormats(gif: $gif)';
  }
}

/// @nodoc
abstract mixin class $MediaFormatsCopyWith<$Res> {
  factory $MediaFormatsCopyWith(
          MediaFormats value, $Res Function(MediaFormats) _then) =
      _$MediaFormatsCopyWithImpl;
  @useResult
  $Res call({GifFormat gif});

  $GifFormatCopyWith<$Res> get gif;
}

/// @nodoc
class _$MediaFormatsCopyWithImpl<$Res> implements $MediaFormatsCopyWith<$Res> {
  _$MediaFormatsCopyWithImpl(this._self, this._then);

  final MediaFormats _self;
  final $Res Function(MediaFormats) _then;

  /// Create a copy of MediaFormats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gif = null,
  }) {
    return _then(_self.copyWith(
      gif: null == gif
          ? _self.gif
          : gif // ignore: cast_nullable_to_non_nullable
              as GifFormat,
    ));
  }

  /// Create a copy of MediaFormats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GifFormatCopyWith<$Res> get gif {
    return $GifFormatCopyWith<$Res>(_self.gif, (value) {
      return _then(_self.copyWith(gif: value));
    });
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _MediaFormats implements MediaFormats {
  const _MediaFormats({required this.gif});
  factory _MediaFormats.fromJson(Map<String, dynamic> json) =>
      _$MediaFormatsFromJson(json);

  @override
  final GifFormat gif;

  /// Create a copy of MediaFormats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MediaFormatsCopyWith<_MediaFormats> get copyWith =>
      __$MediaFormatsCopyWithImpl<_MediaFormats>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MediaFormatsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MediaFormats &&
            (identical(other.gif, gif) || other.gif == gif));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gif);

  @override
  String toString() {
    return 'MediaFormats(gif: $gif)';
  }
}

/// @nodoc
abstract mixin class _$MediaFormatsCopyWith<$Res>
    implements $MediaFormatsCopyWith<$Res> {
  factory _$MediaFormatsCopyWith(
          _MediaFormats value, $Res Function(_MediaFormats) _then) =
      __$MediaFormatsCopyWithImpl;
  @override
  @useResult
  $Res call({GifFormat gif});

  @override
  $GifFormatCopyWith<$Res> get gif;
}

/// @nodoc
class __$MediaFormatsCopyWithImpl<$Res>
    implements _$MediaFormatsCopyWith<$Res> {
  __$MediaFormatsCopyWithImpl(this._self, this._then);

  final _MediaFormats _self;
  final $Res Function(_MediaFormats) _then;

  /// Create a copy of MediaFormats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? gif = null,
  }) {
    return _then(_MediaFormats(
      gif: null == gif
          ? _self.gif
          : gif // ignore: cast_nullable_to_non_nullable
              as GifFormat,
    ));
  }

  /// Create a copy of MediaFormats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GifFormatCopyWith<$Res> get gif {
    return $GifFormatCopyWith<$Res>(_self.gif, (value) {
      return _then(_self.copyWith(gif: value));
    });
  }
}

/// @nodoc
mixin _$GifFormat {
  String get url;
  double get duration;
  String get preview;
  List<int> get dims;
  int get size;

  /// Create a copy of GifFormat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GifFormatCopyWith<GifFormat> get copyWith =>
      _$GifFormatCopyWithImpl<GifFormat>(this as GifFormat, _$identity);

  /// Serializes this GifFormat to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GifFormat &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.preview, preview) || other.preview == preview) &&
            const DeepCollectionEquality().equals(other.dims, dims) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, duration, preview,
      const DeepCollectionEquality().hash(dims), size);

  @override
  String toString() {
    return 'GifFormat(url: $url, duration: $duration, preview: $preview, dims: $dims, size: $size)';
  }
}

/// @nodoc
abstract mixin class $GifFormatCopyWith<$Res> {
  factory $GifFormatCopyWith(GifFormat value, $Res Function(GifFormat) _then) =
      _$GifFormatCopyWithImpl;
  @useResult
  $Res call(
      {String url, double duration, String preview, List<int> dims, int size});
}

/// @nodoc
class _$GifFormatCopyWithImpl<$Res> implements $GifFormatCopyWith<$Res> {
  _$GifFormatCopyWithImpl(this._self, this._then);

  final GifFormat _self;
  final $Res Function(GifFormat) _then;

  /// Create a copy of GifFormat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? duration = null,
    Object? preview = null,
    Object? dims = null,
    Object? size = null,
  }) {
    return _then(_self.copyWith(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as double,
      preview: null == preview
          ? _self.preview
          : preview // ignore: cast_nullable_to_non_nullable
              as String,
      dims: null == dims
          ? _self.dims
          : dims // ignore: cast_nullable_to_non_nullable
              as List<int>,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _GifFormat implements GifFormat {
  const _GifFormat(
      {required this.url,
      required this.duration,
      required this.preview,
      required final List<int> dims,
      required this.size})
      : _dims = dims;
  factory _GifFormat.fromJson(Map<String, dynamic> json) =>
      _$GifFormatFromJson(json);

  @override
  final String url;
  @override
  final double duration;
  @override
  final String preview;
  final List<int> _dims;
  @override
  List<int> get dims {
    if (_dims is EqualUnmodifiableListView) return _dims;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dims);
  }

  @override
  final int size;

  /// Create a copy of GifFormat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GifFormatCopyWith<_GifFormat> get copyWith =>
      __$GifFormatCopyWithImpl<_GifFormat>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GifFormatToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GifFormat &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.preview, preview) || other.preview == preview) &&
            const DeepCollectionEquality().equals(other._dims, _dims) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, duration, preview,
      const DeepCollectionEquality().hash(_dims), size);

  @override
  String toString() {
    return 'GifFormat(url: $url, duration: $duration, preview: $preview, dims: $dims, size: $size)';
  }
}

/// @nodoc
abstract mixin class _$GifFormatCopyWith<$Res>
    implements $GifFormatCopyWith<$Res> {
  factory _$GifFormatCopyWith(
          _GifFormat value, $Res Function(_GifFormat) _then) =
      __$GifFormatCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String url, double duration, String preview, List<int> dims, int size});
}

/// @nodoc
class __$GifFormatCopyWithImpl<$Res> implements _$GifFormatCopyWith<$Res> {
  __$GifFormatCopyWithImpl(this._self, this._then);

  final _GifFormat _self;
  final $Res Function(_GifFormat) _then;

  /// Create a copy of GifFormat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? url = null,
    Object? duration = null,
    Object? preview = null,
    Object? dims = null,
    Object? size = null,
  }) {
    return _then(_GifFormat(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as double,
      preview: null == preview
          ? _self.preview
          : preview // ignore: cast_nullable_to_non_nullable
              as String,
      dims: null == dims
          ? _self._dims
          : dims // ignore: cast_nullable_to_non_nullable
              as List<int>,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
