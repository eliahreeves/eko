import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/interfaces/notification_helper.dart';

Future<bool> isUsernameAvailable(String username) async {
  try {
    return await supabase.rpc(
      'is_username_available',
      params: {'p_username': username},
    );
  } catch (e) {
    debugPrint(e.toString());
    return true;
  }
}

bool isUsernameValid(String username) {
  return username.trim().contains(RegExp(c.userNameReqs));
}

Future<void> addDeviceNotificationToken(String uid) async {
  if (!kIsWeb) {
    try {
      final token = await NotificationHelper.getDeviceToken();
      if (token == null) return;
      // TODO this will need to change
      await supabase.from('notifications').upsert({
        'user_uid': uid,
        'token': token,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      PrefsService.notificationsEnabled = true;
    } catch (e) {
      debugPrint('addDeviceNotificationToken error: $e');
    }
  }
}

Future<void> removeDeviceNotificationToken(String uid) async {
  if (!kIsWeb) {
    try {
      final token = await NotificationHelper.getDeviceToken();
      if (token == null) return;
      await supabase
          .from('notifications')
          .delete()
          .eq('user_uid', uid)
          .eq('token', token);
      PrefsService.notificationsEnabled = false;
    } catch (e) {
      debugPrint('removeDeviceNotificationToken error: $e');
    }
  }
}

Future<String> forgotPassword({
  required String? countryCode,
  required String email,
}) async {
  try {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: c.forgotPasswordURL,
    );
    return 'success';
  } catch (e) {
    return 'unknown';
  }
}

Future<String?> getUidFromUsername(String username) async {
  final data = await supabase
      .from('usernames')
      .select('user_uid')
      .eq('username', username)
      .maybeSingle();
  return data?['user_uid'] as String?;
}

Future<String> verifyPasswordReset(String code) async {
  try {
    final response = await supabase.auth.verifyOTP(
      type: supabase_flutter.OtpType.recovery,
      token: code,
    );
    return response.user?.email ?? '';
  } catch (e) {
    debugPrint('verifyPasswordReset error: $e');
    rethrow;
  }
}

Future<String> resetPassword(String code, String password) async {
  try {
    await supabase.auth.updateUser(
      supabase_flutter.UserAttributes(password: password),
    );
    return 'success';
  } catch (e) {
    debugPrint('resetPassword error: $e');
    return 'unknown';
  }
}
