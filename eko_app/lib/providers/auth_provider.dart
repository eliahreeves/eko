import 'package:flutter/material.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eko_app/types/auth.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:eko_app/interfaces/notification_helper.dart';
import 'package:eko_app/interfaces/user.dart' as user;
import 'package:eko_app/utilities/gauth/supabase_google_oauth.dart';

part '../generated/providers/auth_provider.g.dart';

class SignUpOutcome {
  const SignUpOutcome({this.errorCode, this.needsEmailVerification = false});

  final String? errorCode;
  final bool needsEmailVerification;

  bool get isSuccess => errorCode == null;
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthModel build() {
    _init();
    return AuthModel.loading();
  }

  void _init() {
    final currentSession = supabase.auth.currentSession;
    if (currentSession != null) {
      final user = currentSession.user;
      state = AuthModel(
        uid: user.id,
        isLoading: false,
        email: user.email,
        emailVerified: user.emailConfirmedAt != null,
        creationTime: DateTime.tryParse(user.createdAt),
      );
    }

    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        state = AuthModel.signedOut();
      } else if (data.event == AuthChangeEvent.passwordRecovery) {
        final user = session.user;
        state = state.copyWith(
          uid: user.id,
          isLoading: false,
          email: user.email,
          emailVerified: user.emailConfirmedAt != null,
          creationTime: DateTime.tryParse(user.createdAt),
          pendingPasswordRecovery: true,
        );
      } else {
        final user = session.user;
        state = state.copyWith(
          uid: user.id,
          isLoading: false,
          email: user.email,
          emailVerified: user.emailConfirmedAt != null,
          creationTime: DateTime.tryParse(user.createdAt),
          pendingPasswordRecovery: false,
        );
      }
    });
  }

  void clearPasswordRecovery() {
    state = state.copyWith(pendingPasswordRecovery: false);
  }

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    await signInWithGoogleOAuth(supabase.auth);
  }

  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    required String username,
    required String name,
    required String birthday,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'username': username,
          'name': name,
          'birthday': birthday,
          'bio': '',
          'is_verified': false,
        },
        emailRedirectTo: c.verifyEmailURL,
      );
      final user = response.user;
      final needsEmailVerification =
          response.session == null || user?.emailConfirmedAt == null;
      return SignUpOutcome(needsEmailVerification: needsEmailVerification);
    } on AuthException catch (e) {
      debugPrint(e.message);
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') ||
          msg.contains('already been registered')) {
        return const SignUpOutcome(errorCode: 'email-already-in-use');
      }
      if (msg.contains('invalid email')) {
        return const SignUpOutcome(errorCode: 'invalid-email');
      }
      if (msg.contains('password') && msg.contains('6')) {
        return const SignUpOutcome(errorCode: 'weak-password');
      }
      return const SignUpOutcome(errorCode: 'unknown');
    } catch (e) {
      debugPrint(e.toString());
      return const SignUpOutcome(errorCode: 'unknown');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final uid = state.uid;
      if (uid == null) return;
      await supabase.rpc('delete_user');
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error deleting account: $e');
    }
  }

  Future<void> sendEmailVerification(String email) async {
    try {
      await supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: c.verifyEmailURL,
      );
    } catch (e) {
      debugPrint('Error sending email verification: $e');
    }
  }

  Future<void> refreshEmailVerification() async {
    try {
      final response = await supabase.auth.refreshSession();
      final user = response.user;
      if (user != null) {
        state = state.copyWith(emailVerified: user.emailConfirmedAt != null);
      }
    } catch (e) {
      debugPrint('Error refreshing email verification: $e');
    }
  }

  String? _oauthAvatarUrl() {
    final meta = supabase.auth.currentUser?.userMetadata;
    if (meta == null) return null;
    String? str(Object? v) {
      if (v == null) return null;
      final s = v is String ? v : v.toString();
      final t = s.trim();
      return t.isEmpty ? null : t;
    }

    return str(meta['avatar_url']) ??
        str(meta['picture']) ??
        str(meta['avatarUrl']);
  }

  Future<SignUpOutcome> createGoogleProfile({
    required String username,
    required String name,
    required String birthday,
  }) async {
    try {
      // Parse birthday string MM/DD/YYYY → date expected by the RPC
      final parts = birthday.split('/');
      final birthdayDate = parts.length == 3
          ? '${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}'
          : birthday;

      final avatarUrl = _oauthAvatarUrl();

      final response = await supabase.rpc(
        'create_google_profile',
        params: {
          'p_username': username,
          'p_name': name,
          'p_birthday': birthdayDate,
          'p_profile_picture': avatarUrl,
        },
      );
      if (response is! List || response.isEmpty) {
        return const SignUpOutcome(errorCode: 'unknown');
      }
      final row = Map<String, dynamic>.from(response.first as Map);
      if (row['success'] != true) {
        final msg = (row['error_message'] ?? '').toString().toLowerCase();
        if (msg.contains('username')) {
          return const SignUpOutcome(errorCode: 'username-taken');
        }
        return const SignUpOutcome(errorCode: 'unknown');
      }
      if (avatarUrl != null) {
        try {
          await supabase.auth.updateUser(
            UserAttributes(data: {'profile_picture': avatarUrl}),
          );
        } catch (e) {
          debugPrint('createGoogleProfile auth metadata sync: $e');
        }
      }
      return const SignUpOutcome();
    } on AuthException catch (e) {
      debugPrint('createGoogleProfile auth error: ${e.message}');
      return const SignUpOutcome(errorCode: 'unknown');
    } catch (e) {
      debugPrint('createGoogleProfile error: $e');
      return const SignUpOutcome(errorCode: 'unknown');
    }
  }

  Future<void> registerNotificationsIfNeeded() async {
    final uid = state.uid;
    if (uid == null || uid.isEmpty) return;
    final hasToken = PrefsService.deviceNotificationToken != null;
    if (PrefsService.notificationsEnabled && hasToken) return;
    await NotificationHelper.setupNotifications();
    await user.addDeviceNotificationToken(uid);
  }

  Future<void> refreshDeviceNotificationTokenIfNeeded() async {
    final uid = state.uid;
    if (uid == null || uid.isEmpty) return;
    if (!PrefsService.notificationsEnabled) return;
    await user.refreshDeviceNotificationTokenIfNeeded(uid);
  }
}
