import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eraser/eraser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/following_feed_provider.dart';
import 'package:eko_app/providers/new_feed_provider.dart';
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:unifiedpush/unifiedpush.dart';

class NotificationHelper {
  static NotificationPlatformAdapter get _adapter {
    if (Platform.isIOS) {
      const MethodChannel channel = MethodChannel('PushNotificationChannel');
      return const ApnsNotificationAdapter(channel);
    }
    if (Platform.isAndroid) {
      return const UnifiedPushNotificationAdapter();
    }
    // TODO idk how web  or linux will work
    return const NoopNotificationAdapter();
  }

  static Future<void> setupNotifications() async {
    await _adapter.initialize();
    await _adapter.requestPermissions();
    await _adapter.registerDevice();
  }

  /// For when a user clicks on a notification they received
  static void setupHandlersWithContext(
    BuildContext context,
    void Function() callback,
  ) {
    _adapter.setHandlers(context, callback, _handleNavigationPayload);
  }

  static Future<String?> getDeviceToken() async {
    await _adapter.initialize();
    return _adapter.getDeviceToken();
  }

  static Future<String?> waitForDeviceToken({
    Duration timeout = const Duration(seconds: 8),
    Duration interval = const Duration(milliseconds: 400),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final token = await getDeviceToken();
      if (token != null && token.isNotEmpty) {
        return token;
      }
      await Future.delayed(interval);
    }
    return null;
  }

  /// TODO probably should remove this and track in the DB when apns returns 410, then when user info
  /// is pulled, a bool will determine if its expired and needs to upload a new token.
  /// https://developer.apple.com/forums/thread/682939
  static Future<bool> refreshDeviceTokenIfNeeded({
    Duration minInterval = const Duration(days: 7),
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastChecked = PrefsService.deviceNotificationTokenLastCheckedAt;
    if (lastChecked != null && now - lastChecked < minInterval.inMilliseconds) {
      return false;
    }
    PrefsService.deviceNotificationTokenLastCheckedAt = now;
    final token = await getDeviceToken();
    if (token == null || token.isEmpty) {
      PrefsService.notificationsEnabled = false;
      PrefsService.deviceNotificationToken = null;
      return false;
    }
    final previous = PrefsService.deviceNotificationToken;
    if (previous == token) return false;
    PrefsService.deviceNotificationToken = token;
    return true;
  }

  static Future<void> _handleNavigationPayload(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final type = data['type'] as String?;
    final path = data['path'] as String?;
    if (type == null || path == null) {
      return;
    }
    Eraser.clearAllAppNotifications();
    switch (type) {
      case 'comment':
        context.push('/feed/post/$path');
        break;
      case 'post':
        List<String> parts = path.split('/');
        String lastPart = parts.last;
        context.push('/feed/post/$lastPart').then((value) {
          if (context.mounted) context.go('/feed', extra: true);
        });
        break;
      case 'tag':
        List<String> parts = path.split('/');
        String lastPart = parts.last;
        context.push('/feed/post/$lastPart').then((value) {
          if (context.mounted) context.go('/feed', extra: true);
        });
        break;
      case 'follow':
        context.push('/users/_?uid=$path');
        break;
    }
  }
}

typedef NotificationPayloadHandler = Future<void> Function(
    BuildContext context, Map<String, dynamic> data);

abstract class NotificationPlatformAdapter {
  const NotificationPlatformAdapter();
  Future<void> initialize();
  Future<void> requestPermissions();
  Future<void> registerDevice();
  Future<String?> getDeviceToken();
  void setHandlers(
    BuildContext context,
    void Function() callback,
    NotificationPayloadHandler handler,
  );
}

class ApnsNotificationAdapter extends NotificationPlatformAdapter {
  final MethodChannel _channel;
  const ApnsNotificationAdapter(this._channel);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {
    await _channel.invokeMethod('requestNotificationPermissions');
  }

  @override
  Future<void> registerDevice() async {
    await _channel.invokeMethod('registerForPushNotifications');
  }

  @override
  Future<String?> getDeviceToken() async {
    try {
      return await _channel.invokeMethod<String>('retrieveDeviceToken');
    } on PlatformException {
      return null;
    }
  }

  @override
  void setHandlers(
    BuildContext context,
    void Function() callback,
    NotificationPayloadHandler handler,
  ) {
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'onPushNotification') {
        return;
      }
      final data = _normalizePayload(call.arguments);
      if (data.isEmpty) {
        return;
      }
      await handler(context, data);
      callback();
    });
  }

  Map<String, dynamic> _normalizePayload(dynamic arguments) {
    if (arguments is Map) {
      return arguments.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }
}

class UnifiedPushNotificationAdapter extends NotificationPlatformAdapter {
  const UnifiedPushNotificationAdapter();

  static const String _instance = 'default';
  static void Function(String?)? _onEndpoint;
  static void Function()? _onMessage;
  static NotificationPayloadHandler? _onPayload;
  static BuildContext? _handlerContext;
  static bool _initialized = false;
  static Completer<String?>? _tokenCompleter;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    try {
      debugPrint('[UnifiedPush] initialize start');
      await UnifiedPush.initialize(
        onNewEndpoint: (endpoint, instance) {
          if (instance != _instance) return;
          debugPrint(
              '[UnifiedPush] onNewEndpoint instance=$instance url=${endpoint.url}');
          PrefsService.deviceNotificationToken = endpoint.url;
          PrefsService.notificationsEnabled = true;
          _onEndpoint?.call(endpoint.url);
          _completeToken(endpoint.url);
        },
        onRegistrationFailed: (reason, instance) {
          if (instance != _instance) return;
          debugPrint(
              '[UnifiedPush] onRegistrationFailed instance=$instance reason=$reason');
          PrefsService.deviceNotificationToken = null;
          PrefsService.notificationsEnabled = false;
          _onEndpoint?.call(null);
          _completeToken(null);
        },
        onUnregistered: (instance) {
          if (instance != _instance) return;
          debugPrint('[UnifiedPush] onUnregistered instance=$instance');
          PrefsService.deviceNotificationToken = null;
          PrefsService.notificationsEnabled = false;
          _onEndpoint?.call(null);
          _completeToken(null);
        },
        onMessage: (message, instance) async {
          if (instance != _instance) return;
          debugPrint(
              '[UnifiedPush] onMessage instance=$instance contentType=${message.content.runtimeType}');
          final payload = _decodePayload(message.content);
          final context = _handlerContext;
          final handler = _onPayload;
          debugPrint(
              '[UnifiedPush] onMessage payloadKeys=${payload.keys.join(",")}');
          if (context != null && handler != null && payload.isNotEmpty) {
            await handler(context, payload);
          }
          _onMessage?.call();
        },
        onTempUnavailable: (instance) {
          if (instance != _instance) return;
          debugPrint('[UnifiedPush] onTempUnavailable instance=$instance');
        },
      );
      debugPrint('[UnifiedPush] initialize complete');
    } catch (_) {
      _initialized = false;
      debugPrint('[UnifiedPush] initialize failed');
      rethrow;
    }
  }

  static Map<String, dynamic> _decodePayload(dynamic content) {
    if (content == null) return {};
    String payload;
    if (content is Uint8List) {
      if (content.isEmpty) return {};
      debugPrint(
          '[UnifiedPush] decode payload from bytes length=${content.length}');
      payload = utf8.decode(content);
    } else if (content is String) {
      if (content.isEmpty) return {};
      debugPrint(
          '[UnifiedPush] decode payload from string length=${content.length}');
      payload = content;
    } else {
      debugPrint(
          '[UnifiedPush] decode payload unsupported type=${content.runtimeType}');
      return {};
    }
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    debugPrint('[UnifiedPush] decode payload failed');
    return {};
  }

  static void _completeToken(String? token) {
    final completer = _tokenCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(token);
    }
  }

  static Future<String?> _pickDistributor(BuildContext context) async {
    final distributors = await UnifiedPush.getDistributors();
    debugPrint('[UnifiedPush] distributors count=${distributors.length}');
    if (distributors.isEmpty) return null;
    if (!context.mounted) return null;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.outlineVariant,
          title: const Text('Select a distributor'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: distributors.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final distributor = distributors[index];
                final name = distributor.split('.').last;
                return ListTile(
                  title: Text(name),
                  subtitle: Text(distributor),
                  onTap: () => Navigator.of(context).pop(distributor),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Future<void> initialize() async {
    await _ensureInitialized();
  }

  @override
  Future<void> requestPermissions() async {
    await _ensureInitialized();
    debugPrint('[UnifiedPush] requestPermissions start');
    final success = await UnifiedPush.tryUseCurrentOrDefaultDistributor();
    debugPrint(
        '[UnifiedPush] tryUseCurrentOrDefaultDistributor success=$success');
    if (success) return;
    final context = _handlerContext;
    if (context == null) return;
    final choice = await _pickDistributor(context);
    if (choice == null) return;
    debugPrint('[UnifiedPush] saveDistributor choice=$choice');
    await UnifiedPush.saveDistributor(choice);
  }

  @override
  Future<void> registerDevice() async {
    await _ensureInitialized();
    if (_tokenCompleter == null || _tokenCompleter!.isCompleted) {
      _tokenCompleter = Completer<String?>();
    }
    debugPrint('[UnifiedPush] registerDevice instance=$_instance');
    await UnifiedPush.register(instance: _instance);
  }

  @override
  Future<String?> getDeviceToken() async {
    await _ensureInitialized();
    final existing = PrefsService.deviceNotificationToken;
    debugPrint(
        '[UnifiedPush] getDeviceToken existing=${existing?.isNotEmpty == true}');
    if (existing != null && existing.isNotEmpty) return existing;
    await registerDevice();
    _tokenCompleter ??= Completer<String?>();
    try {
      final token =
          await _tokenCompleter!.future.timeout(const Duration(seconds: 8));
      debugPrint(
          '[UnifiedPush] getDeviceToken resolved=${token?.isNotEmpty == true}');
      if (token != null && token.isNotEmpty) {
        PrefsService.deviceNotificationToken = token;
      }
      return token;
    } on TimeoutException {
      debugPrint('[UnifiedPush] getDeviceToken timeout');
      return null;
    }
  }

  @override
  void setHandlers(
    BuildContext context,
    void Function() callback,
    NotificationPayloadHandler handler,
  ) {
    _handlerContext = context;
    _onMessage = callback;
    _onPayload = handler;
    _onEndpoint = (endpoint) {
      debugPrint(
          '[UnifiedPush] onEndpoint handler endpoint=${endpoint?.isNotEmpty == true}');
      PrefsService.deviceNotificationToken = endpoint;
      PrefsService.notificationsEnabled =
          endpoint != null && endpoint.isNotEmpty;
    };
  }
}

class NoopNotificationAdapter extends NotificationPlatformAdapter {
  const NoopNotificationAdapter();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> registerDevice() async {}

  @override
  Future<String?> getDeviceToken() async {
    return null;
  }

  @override
  void setHandlers(
    BuildContext context,
    void Function() callback,
    NotificationPayloadHandler handler,
  ) {}
}

class NotificationHandler extends ConsumerStatefulWidget {
  final Widget child;
  const NotificationHandler({super.key, required this.child});

  @override
  ConsumerState<NotificationHandler> createState() =>
      _NotificationHandlerState();
}

class _NotificationHandlerState extends ConsumerState<NotificationHandler> {
  @override
  void initState() {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    NotificationHelper.setupHandlersWithContext(context, () {
      ref.read(followingFeedProvider.notifier).refresh();
      ref.read(newFeedProvider.notifier).refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
