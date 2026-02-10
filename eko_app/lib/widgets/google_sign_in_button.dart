import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/custom_widgets/error_snack_bar.dart';
import 'package:eko_app/providers/auth_provider.dart';

class GoogleSignInButton extends ConsumerStatefulWidget {
  final String text;

  const GoogleSignInButton({
    super.key,
    this.text = 'Continue with Google',
  });

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
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : _handleGoogleSignIn,
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Image.asset(
                'images/google_logo.png',
                height: 24,
                width: 24,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image doesn't exist
                  return const Icon(Icons.login, size: 24);
                },
              ),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            widget.text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
    );
  }
}
