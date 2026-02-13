import 'package:freezed_annotation/freezed_annotation.dart';

part '../generated/types/gif_model.freezed.dart';
part '../generated/types/gif_model.g.dart';

@freezed
abstract class KlipyResponse with _$KlipyResponse {
  @JsonSerializable(explicitToJson: true)
  const factory KlipyResponse({required List<KlipyResult> results}) =
      _KlipyResponse;

  factory KlipyResponse.fromJson(Map<String, dynamic> json) =>
      _$KlipyResponseFromJson(json);
}

@freezed
abstract class KlipyResult with _$KlipyResult {
  @JsonSerializable(explicitToJson: true)
  const factory KlipyResult({
    required String id,
    required String title,
    @JsonKey(name: 'media_formats') required MediaFormats mediaFormats,
    @JsonKey(name: 'content_description') String? contentDescription,
    required String itemurl,
    required String url,
    required List<String> tags,
  }) = _KlipyResult;

  factory KlipyResult.fromJson(Map<String, dynamic> json) =>
      _$KlipyResultFromJson(json);
}

@freezed
abstract class MediaFormats with _$MediaFormats {
  @JsonSerializable(explicitToJson: true)
  const factory MediaFormats({required GifFormat gif}) = _MediaFormats;

  factory MediaFormats.fromJson(Map<String, dynamic> json) =>
      _$MediaFormatsFromJson(json);
}

@freezed
abstract class GifFormat with _$GifFormat {
  @JsonSerializable(explicitToJson: true)
  const factory GifFormat({
    required String url,
    required double duration,
    required String preview,
    required List<int> dims,
    required int size,
  }) = _GifFormat;

  factory GifFormat.fromJson(Map<String, dynamic> json) =>
      _$GifFormatFromJson(json);
}
