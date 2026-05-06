import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/widgets/auth/auth_app_bar.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/auth/auth_divider.dart';
import 'package:eko_app/widgets/auth/create_password.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/widgets/inputs/custom_input_field.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final currentPasswordFocus = FocusNode();
  final newPasswordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  bool isLoading = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    currentPasswordFocus.dispose();
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = AppLocalizations.of(context)!;
    final email = ref.read(authProvider).email;
    if (email == null || email.isEmpty) {
      showSnackBar(
        text: l10n.defaultErrorBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      return;
    }
    if (currentPasswordController.text.isEmpty) {
      currentPasswordFocus.requestFocus();
      return;
    }
    if (!isValidSimplePassword(
      newPasswordController.text,
      confirmPasswordController.text,
    )) {
      showSnackBar(
        text: l10n.weakPasswordBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      return;
    }

    setState(() => isLoading = true);
    await ref
        .read(authProvider.notifier)
        .signIn(email: email, password: currentPasswordController.text);

    final updateResult = await ref
        .read(authProvider.notifier)
        .updatePassword(newPasswordController.text);
    if (!mounted) return;
    setState(() => isLoading = false);

    if (updateResult == 'success') {
      showSnackBar(text: l10n.passwordChangedBody, context: context);
      context.pop();
      return;
    }
    if (updateResult == 'weak-password') {
      showSnackBar(
        text: l10n.weakPasswordBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      return;
    }
    if (updateResult == 'requires-recent-login') {
      context.pushNamed(
        're_auth',
        pathParameters: {
          'username': ref.read(currentUserProvider).user.username,
        },
      );
      return;
    }
    showSnackBar(
      text: l10n.defaultErrorBody,
      context: context,
      variant: SnackBarVariant.destructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: const AuthAppBar(),
      body: Center(
        child: SizedBox(
          width: width,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(
              horizontal: width * c.authPaddingHorizontal,
            ),
            children: [
              SizedBox(height: height * .04),
              SizedBox(
                height: height * .08,
                child: Align(
                  child: Text(
                    l10n.changePassword,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const AuthDivider(indent: 20, endIndent: 20),
              SizedBox(height: height * .02),
              CustomInputField(
                textInputAction: TextInputAction.next,
                focus: currentPasswordFocus,
                label: l10n.currentPassword,
                controller: currentPasswordController,
                inputType: TextInputType.visiblePassword,
                password: true,
                onEditingComplete: () => newPasswordFocus.requestFocus(),
              ),
              CreatePassword(
                passwordController: newPasswordController,
                confirmPasswordController: confirmPasswordController,
                passwordFocus: newPasswordFocus,
                confirmPasswordFocus: confirmPasswordFocus,
              ),
              SizedBox(height: c.authSectionSpacing),
              AuthButton.primary(
                label: l10n.changePassword,
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
