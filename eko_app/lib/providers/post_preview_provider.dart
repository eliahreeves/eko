import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/utilities/shared_pref_service.dart';

part '../generated/providers/post_preview_provider.g.dart';

@Riverpod(keepAlive: true)
class PostPreview extends _$PostPreview {
  @override
  bool build() {
    return PrefsService.showPostPreview;
  }

  void toggle() {
    final newValue = !state;
    PrefsService.showPostPreview = newValue;
    state = newValue;
  }

  bool hasShownInfo() {
    return PrefsService.hasShownPreviewInfo;
  }

  void markInfoShown() {
    PrefsService.hasShownPreviewInfo = true;
  }
}
