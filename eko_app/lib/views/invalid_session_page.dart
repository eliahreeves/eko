import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/presence_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/auth/auth_button.dart';

class InvalidSessionPage extends ConsumerWidget {
  const InvalidSessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.8,
                child: Text(
                  AppLocalizations.of(context)!.invalidSession,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: c.authElementSpacing),
              AuthButton.primary(
                label: AppLocalizations.of(context)!.cont,
                onPressed: () =>
                    ref.read(presenceProvider.notifier).validateSession(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
