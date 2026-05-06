import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/providers/pending_deep_link_provider.g.dart';

@Riverpod(keepAlive: true)
class PendingDeepLink extends _$PendingDeepLink {
  @override
  String? build() => null;

  void set(String path) => state = path;

  String? consume() {
    final value = state;
    state = null;
    return value;
  }
}
