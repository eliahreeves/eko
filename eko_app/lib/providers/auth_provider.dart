import 'package:flutter/material.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eko_app/types/auth.dart';
import 'package:eko_app/utilities/supabase_ref.dart';

part '../generated/providers/auth_provider.g.dart';

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

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return 'success';
    } on AuthException catch (e) {
      debugPrint(e.message);
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid') || msg.contains('credentials')) {
        return 'wrong-password';
      }
      if (msg.contains('invalid email')) {
        return 'invalid-email';
      }
      return 'unknown';
    } catch (e) {
      debugPrint(e.toString());
      return 'unknown';
    }
  }

  Future<String> signUp({
    required String email,
    required String password,
    required String username,
    required String name,
    required String birthday,
  }) async {
    try {
      await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'username': username,
          'name': name,
          'birthday': birthday,
          'bio': '',
          'is_verified': false,
        },
      );
      return 'success';
    } on AuthException catch (e) {
      debugPrint(e.message);
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') ||
          msg.contains('already been registered')) {
        return 'email-already-in-use';
      }
      if (msg.contains('invalid email')) {
        return 'invalid-email';
      }
      if (msg.contains('password') && msg.contains('6')) {
        return 'weak-password';
      }
      return 'unknown';
    } catch (e) {
      debugPrint(e.toString());
      return 'unknown';
    }
  }

  Future<void> deleteAccount() async {
    try {
      final uid = state.uid;
      if (uid == null) return;
      await supabase.rpc('delete_user', params: {'p_uid': uid});
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error deleting account: $e');
    }
  }

  Future<void> sendEmailVerification() async {
    final email = state.email;
    if (email == null) return;
    try {
      await supabase.auth.resend(type: OtpType.signup, email: email);
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
}
