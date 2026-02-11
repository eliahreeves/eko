import 'package:flutter/material.dart';
import 'package:eko_app/utilities/constants.dart' as c;

/// Standard scaffold layout for auth pages
/// Provides consistent structure: SafeArea, Center, ConstrainedBox, SingleChildScrollView
class AuthScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  const AuthScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: c.maxAuthWidth),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(
                    horizontal: width * c.authPaddingHorizontal),
                child: body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
