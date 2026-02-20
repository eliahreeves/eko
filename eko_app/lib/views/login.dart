import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/widgets/common/download_button.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/interfaces/user.dart' as user;
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/widgets/auth/google_sign_in_button.dart';
import 'package:eko_app/widgets/common/icons.dart';
import 'package:eko_app/widgets/inputs/custom_input_field.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/auth/auth_app_bar.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/auth/auth_divider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  bool isLoading = false;

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  int handleError(String errorCode) {
    final l10n = AppLocalizations.of(context)!;
    switch (errorCode) {
      case 'success':
        return 0;
      case 'invalid-email':
        showSnackBar(
            text: l10n.invalidEmailBody,
            context: context,
            variant: SnackBarVariant.destructive);
        return 1;
      default:
        showSnackBar(
            text: l10n.loginFailedBody,
            context: context,
            variant: SnackBarVariant.destructive);
        return 1;
    }
  }

  void loginPressed() async {
    if (emailController.text == '') {
      emailFocus.requestFocus();
    } else if (passwordController.text == '') {
      passwordFocus.requestFocus();
    } else {
      setState(() {
        isLoading = true;
      });
      if (handleError(
            await ref.read(authProvider.notifier).signIn(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                ),
          ) ==
          0) {}
      setState(() {
        isLoading = false;
      });
    }
  }

  void forgotPasswordPressed(String? countryCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isSending = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
              title: Text(l10n.resetPassword),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomInputField(
                      autofillHints: [AutofillHints.email],
                      label: l10n.email,
                      controller: emailController,
                      inputType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () {
                    context.pop();
                  },
                ),
                TextButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          setDialogState(() {
                            isSending = true;
                          });
                          // Vague approach: always show success message unless it's a structural error
                          // and don't pop until done
                          await user.forgotPassword(
                            countryCode: countryCode,
                            email: emailController.text.trim(),
                          );

                          if (context.mounted) {
                            context.pop();
                            showSnackBar(
                              text: l10n.forgotPasswordBody,
                              context: context,
                            );
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.sendResetLink),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AuthAppBar(),
      floatingActionButton: downloadButtonIfWeb(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Center(
          child: SizedBox(
            width: c.widthGetter(context),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: width * c.authPaddingHorizontal,
              ),
              child: Column(
                children: [
                  SizedBox(height: height * .04),
                  SizedBox(
                    height: height * .22,
                    width: width * 0.7,
                    child: Eko(useDefault: true),
                  ),
                  SizedBox(height: height * .04),
                  AutofillGroup(
                    child: Column(
                      children: [
                        CustomInputField(
                          autofillHints: [AutofillHints.email],
                          focus: emailFocus,
                          label: l10n.email,
                          controller: emailController,
                          inputType: TextInputType.emailAddress,
                        ),
                        CustomInputField(
                          autofillHints: [AutofillHints.password],
                          textInputAction: TextInputAction.go,
                          onEditingComplete: () => loginPressed(),
                          focus: passwordFocus,
                          label: l10n.password,
                          controller: passwordController,
                          inputType: TextInputType.visiblePassword,
                          password: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: c.authElementSpacing),
                  AuthButton.primary(
                    label: l10n.logIn,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : loginPressed,
                  ),
                  SizedBox(
                    width: c.widthGetter(context) * 0.9,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => forgotPasswordPressed(l10n.localeName),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                      ),
                      child: Text(
                        l10n.forgotPassword,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: c.authSectionSpacing),
                  const AuthDivider(indent: 20, endIndent: 20),
                  const SizedBox(height: c.authElementSpacing),
                  const GoogleSignInButton(),
                  SizedBox(height: height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
