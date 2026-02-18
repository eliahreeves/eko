import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/widgets/auth/create_password.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/errors/dialogs.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/auth/auth_app_bar.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/auth/auth_divider.dart';

//Forgot password page + email verification link handler

class AuthActionInterface extends ConsumerStatefulWidget {
  final Map<String, String> urlData;
  const AuthActionInterface({super.key, required this.urlData});

  @override
  ConsumerState<AuthActionInterface> createState() =>
      _AuthActionInterfaceState();
}

class _AuthActionInterfaceState extends ConsumerState<AuthActionInterface> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  String email = '';

  bool isLoading = false;

  Future<void> setPasswordPressed() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (passwordController.text == '') {
      passwordFocus.requestFocus();
    } else {
      if (isValidPassword(
        passwordController.text,
        confirmPasswordController.text,
      )) {
        setState(() {
          isLoading = true;
        });
        if ((await resetPassword(
              widget.urlData['oobCode'] ?? '',
              passwordController.text,
            )) ==
            'success') {
          if (mounted) {
            showMyDialog(
              AppLocalizations.of(context)!.passwordResetTitle,
              AppLocalizations.of(context)!.passwordResetBody,
              [AppLocalizations.of(context)!.ok],
              [
                () {
                  context.pop();
                  context.go('/login');
                },
              ],
              context,
            );
          }
        } else {
          passwordController.text = '';
          confirmPasswordController.text = '';
          setState(() {
            index = 1;
          });
        }

        setState(() {
          isLoading = false;
        });
      } else {
        showSnackBar(
          text: AppLocalizations.of(context)!.weakPasswordBody,
          context: context,
          time: 3000,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mode = widget.urlData['mode'] ?? '';
      final oobCode = widget.urlData['oobCode'] ?? '';

      if (mode == 'verifyEmail' && oobCode.isNotEmpty) {
        try {
          await FirebaseAuth.instance.applyActionCode(oobCode);
          if (!mounted) return;
          await ref.read(authProvider.notifier).refreshEmailVerification();
          if (!mounted) return;
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            context.go('/feed');
          } else {
            context.go('/login');
          }
        } on FirebaseAuthException {
          if (mounted) setState(() => index = 1);
        }
        return;
      }

      if (mode == 'resetPassword') {
        try {
          final userEmail = await verifyPasswordReset(oobCode);
          if (mounted) {
            setState(() {
              email = userEmail;
              index = 2;
            });
          }
        } on FirebaseAuthException {
          if (mounted) setState(() => index = 1);
        }
      } else {
        if (mounted) setState(() => index = 1);
      }
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordFocus.dispose();
    confirmPasswordController.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = c.widthGetter(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: index == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (index == 2) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: index != 0
            ? AuthAppBar(
                onBack: () => context.go('/'),
              )
            : null,
        body: Center(
          child: SizedBox(
            width: width,
            child: IndexedStack(
              index: index,
              children: <Widget>[
                Center(child: LoadingSpinner()),
                // Index 1: Error State
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * c.authPaddingHorizontal,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        l10n.defaultErrorTittle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const AuthDivider(indent: 20, endIndent: 20),
                      const SizedBox(height: c.authSectionSpacing),
                      Text(
                        l10n.badAuthState,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: c.authSectionSpacing),
                      AuthButton.primary(
                        label: l10n.exit,
                        onPressed: () => context.go('/'),
                      ),
                    ],
                  ),
                ),
                // Index 2: Reset Password Form
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * c.authPaddingHorizontal,
                  ),
                  child: Center(
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        SizedBox(
                          height: height * .08,
                          child: Align(
                            child: Text(
                              l10n.resetPassword,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const AuthDivider(indent: 20, endIndent: 20),
                        SizedBox(height: height * 0.02),
                        Text(
                          '${l10n.resetPasswordPromt} $email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: c.authElementSpacing),
                        CreatePassword(
                          passwordController: passwordController,
                          confirmPasswordController: confirmPasswordController,
                          passwordFocus: passwordFocus,
                          confirmPasswordFocus: confirmPasswordFocus,
                        ),
                        SizedBox(height: c.authSectionSpacing),
                        AuthButton.primary(
                          label: l10n.setPassword,
                          isLoading: isLoading,
                          onPressed: isLoading ? null : setPasswordPressed,
                        ),
                        const SizedBox(height: c.authElementSpacing),
                        AuthButton.tertiary(
                          label: l10n.cancel,
                          onPressed: () => context.go('/'),
                        ),
                        SizedBox(height: height * 0.03),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
