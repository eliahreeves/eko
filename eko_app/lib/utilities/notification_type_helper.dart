import 'package:flutter/foundation.dart';
import 'package:eko_app/types/notification.dart';

String deviceTypeFromPlatform() {
  if (kIsWeb) return DeviceType.browser.name;
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return DeviceType.ios.name;
    case TargetPlatform.android:
      return DeviceType.android.name;
    case TargetPlatform.linux:
      return DeviceType.linux.name;
    default:
      return DeviceType.browser.name;
  }
}

String notificationTypeFromPlatform() {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return NotificationType.apns.name;
  }
  return NotificationType.web_push.name;
}
