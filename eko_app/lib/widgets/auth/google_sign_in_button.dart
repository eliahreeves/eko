import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class GoogleSignInButton extends ConsumerStatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
  bool isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      showSnackBar(
        text: 'Failed to sign in with Google. Please try again.',
        context: context,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: c.authButtonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.outline),
          foregroundColor: theme.colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onSurface,
                ),
              )
            : Text(
                AppLocalizations.of(context)!.continueWithGoogle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
