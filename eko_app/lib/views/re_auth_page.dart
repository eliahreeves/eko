import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/widgets/inputs/custom_input_field.dart';
import 'package:eko_app/widgets/errors/dialogs.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/auth/auth_app_bar.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/auth/auth_divider.dart';

class ReAuthPage extends ConsumerStatefulWidget {
  const ReAuthPage({super.key});

  @override
  ConsumerState<ReAuthPage> createState() => _ReAuthPageState();
}

class _ReAuthPageState extends ConsumerState<ReAuthPage> {
  final passwordController = TextEditingController();
  final passwordFocus = FocusNode();
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  int handleError(String errorCode) {
    switch (errorCode) {
      case 'success':
        return 0;
      case 'wrong-password':
        showMyDialog(
          AppLocalizations.of(context)!.wrongPasswordTittle,
          AppLocalizations.of(context)!.wrongPasswordBody,
          [AppLocalizations.of(context)!.tryAgain],
          [context.pop],
          context,
        );
        return 1;
      case 'user-disabled':
        showMyDialog(
          AppLocalizations.of(context)!.userDisabledTittle,
          AppLocalizations.of(context)!.userDisabledBody,
          [AppLocalizations.of(context)!.tryAgain],
          [context.pop],
          context,
        );
        return 1;
      default:
        showMyDialog(
          AppLocalizations.of(context)!.defaultErrorTittle,
          AppLocalizations.of(context)!.defaultErrorBody,
          [AppLocalizations.of(context)!.tryAgain],
          [context.pop],
          context,
        );
        return 1;
    }
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
                    l10n.deleteAccount,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const AuthDivider(indent: 20, endIndent: 20),
              SizedBox(height: height * .04),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.deleteAcountReAuthWarning,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: height * .06),
              CustomInputField(
                textInputAction: TextInputAction.go,
                focus: passwordFocus,
                label: l10n.password,
                controller: passwordController,
                inputType: TextInputType.visiblePassword,
                password: true,
              ),
              const SizedBox(height: c.authElementSpacing),
              AuthButton.primary(
                label: l10n.deleteAccount,
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        final password = passwordController.text;
                        if (password == '') {
                          passwordFocus.requestFocus();
                        } else {
                          final result =
                              await ref.read(authProvider.notifier).signIn(
                                    password: password,
                                    email: ref.read(authProvider).email!,
                                  );
                          if (handleError(result) == 0) {
                            await ref
                                .read(authProvider.notifier)
                                .deleteAccount();
                          }
                        }
                        setState(() => isLoading = false);
                      },
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
