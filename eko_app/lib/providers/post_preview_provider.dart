import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/utilities/shared_pref_service.dart';

part '../generated/providers/post_preview_provider.g.dart';

const String _previewKey = 'SHOW_POST_PREVIEW';
const String _infoKey = 'HAS_SHOWN_PREVIEW_INFO';

@Riverpod(keepAlive: true)
class PostPreview extends _$PostPreview {
  @override
  bool build() {
    final prefs = PrefsService.instance;
    return prefs.getBool(_previewKey) ?? true;
  }

  void toggle() {
    final prefs = PrefsService.instance;
    final newValue = !state;
    prefs.setBool(_previewKey, newValue);
    state = newValue;
  }

  bool hasShownInfo() {
    final prefs = PrefsService.instance;
    return prefs.getBool(_infoKey) ?? false;
  }

  void markInfoShown() {
    final prefs = PrefsService.instance;
    prefs.setBool(_infoKey, true);
  }
}
