import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/nav_bar_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/auth/auth_app_bar.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  bool _resendLoading = false;
  bool _checkLoading = false;
  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        if (mounted) setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _signOutAndGoHome() async {
    await ref.read(currentUserProvider.notifier).signOut();
    ref.read(navBarProvider.notifier).enable();
    if (mounted) context.go('/');
  }

  Future<void> _resend() async {
    if (_resendLoading || _resendCountdown > 0) return;
    setState(() => _resendLoading = true);
    try {
      await ref.read(authProvider.notifier).sendEmailVerification();
      _startTimer();
    } on FirebaseAuthException catch (_) {
    } finally {
      if (mounted) setState(() => _resendLoading = false);
    }
  }

  /// Refreshes auth state
  Future<void> _checkVerified() async {
    if (_checkLoading) return;
    setState(() => _checkLoading = true);
    try {
      await ref.read(authProvider.notifier).reloadAuthUser();
    } finally {
      if (mounted) setState(() => _checkLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = c.widthGetter(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AuthAppBar(onBack: _signOutAndGoHome),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: c.maxAuthWidth),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: width * c.authPaddingHorizontal,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_lock_outlined,
                    size: 100,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: c.authSectionSpacing),
                  Text(
                    l10n.verifyEmailTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: c.authElementSpacing),
                  Text(
                    l10n.verifyEmailBody,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: c.authSectionSpacing * 1.5),
                  AuthButton.primary(
                    label: _resendCountdown > 0
                        ? l10n.resendInSeconds(_resendCountdown)
                        : l10n.resendVerificationEmail,
                    isLoading: _resendLoading,
                    onPressed: (_resendLoading || _resendCountdown > 0)
                        ? null
                        : _resend,
                  ),
                  const SizedBox(height: c.authElementSpacing),
                  AuthButton.secondary(
                    label: l10n.iveVerifiedMyEmail,
                    isLoading: _checkLoading,
                    onPressed: _checkLoading ? null : _checkVerified,
                  ),
                  SizedBox(height: c.authSectionSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
