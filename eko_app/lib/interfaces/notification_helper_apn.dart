part of 'notification_helper.dart';

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
  Future<String?> getDeviceToken({bool forBackendSync = false}) async {
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
