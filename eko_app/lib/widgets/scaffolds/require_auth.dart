import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/email_verification_cutoff_provider.dart';
import 'package:eko_app/providers/presence_provider.dart';
import 'package:eko_app/views/invalid_session_page.dart';
import 'package:eko_app/views/verify_email_page.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';

class RequireAuth extends ConsumerWidget {
  final Widget child;
  const RequireAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = ref.watch(currentUserProvider);
    final cutoffAsync = ref.watch(emailVerificationCutoffProvider);
    final online = ref.watch(presenceProvider);

    if (auth.isLoading) {
      return const Center(child: LoadingSpinner());
    }
    if (auth.uid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return const Center(child: LoadingSpinner());
    }
    if (user.user.uid.isEmpty) {
      return const Center(child: LoadingSpinner());
    }
    if (!cutoffAsync.isLoading) {
      final cutoffDate = cutoffAsync.maybeWhen<DateTime?>(
        data: (d) => d,
        orElse: () => null,
      );
      final mustVerify =
          auth.emailVerified == false &&
          auth.creationTime != null &&
          cutoffDate != null &&
          !auth.creationTime!.isBefore(cutoffDate);
      if (mustVerify) {
        return const VerifyEmailPage();
      }
    }
    if (!online.valid) {
      return InvalidSessionPage();
    }
    return child;
  }
}
