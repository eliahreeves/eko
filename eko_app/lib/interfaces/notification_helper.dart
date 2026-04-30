import 'dart:io';
import 'package:eraser/eraser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/following_feed_provider.dart';
import 'package:eko_app/providers/new_feed_provider.dart';

class NotificationHelper {
  static NotificationPlatformAdapter get _adapter {
    if (Platform.isIOS) {
      const MethodChannel channel = MethodChannel('PushNotificationChannel');
      return const ApnsNotificationAdapter(channel);
    }
    if (Platform.isLinux || Platform.isAndroid) {
      return const UnifiedPushNotificationAdapter();
    }
    return const NoopNotificationAdapter();
  }

  static Future<void> setupNotifications() async {
    await _adapter.initialize();
  }

  /// For when a user clicks on a notification they received
  static void setupNotificationsWithContext(
    BuildContext context,
    void Function() callback,
  ) {
    _adapter.setHandlers(context, callback, _handleNavigationPayload);
  }

  static Future<String?> getDeviceToken() async {
    return _adapter.getDeviceToken();
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
  Future<void> initialize() async {
    await requestPermissions();
    await registerDevice();
  }

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

// TODO UP
class UnifiedPushNotificationAdapter extends NotificationPlatformAdapter {
  const UnifiedPushNotificationAdapter();

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
    if (Platform.isLinux) {
      return;
    }
    NotificationHelper.setupNotificationsWithContext(context, () {
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
