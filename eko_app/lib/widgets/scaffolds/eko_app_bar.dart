import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EkoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EkoAppBar({
    super.key,
    this.title,
    this.actions = const [],
    this.onBack,
    this.showBackButton = true,
    this.backgroundColor,
    this.elevation = 0,
    this.scrolledUnderElevation,
    this.titleSpacing,

    /// When true, [title] spans the toolbar ([titleSpacing] 0, no default
    /// leading). Use when back/actions are laid out inside [title], e.g.
    /// profile loading/error chrome.
    this.embedLeadingInTitle = false,
    this.bottom,
  });

  final Widget? title;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final bool showBackButton;
  final Color? backgroundColor;
  final double elevation;
  final double? scrolledUnderElevation;
  final double? titleSpacing;
  final bool embedLeadingInTitle;
  final PreferredSizeWidget? bottom;

  static TextStyle titleTextStyle(BuildContext context) => TextStyle(
        fontWeight: FontWeight.normal,
        color: Theme.of(context).colorScheme.onSurface,
      );

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final Widget? leading = embedLeadingInTitle
        ? null
        : (showBackButton
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: onBack ?? () => context.pop(),
              )
            : null);

    final Widget? titleWidget = title == null
        ? null
        : embedLeadingInTitle
            ? title
            : DefaultTextStyle.merge(
                style: titleTextStyle(context),
                child: title!,
              );

    return AppBar(
      leading: leading,
      automaticallyImplyLeading: false,
      titleSpacing: embedLeadingInTitle ? 0 : titleSpacing,
      title: titleWidget,
      actions: actions,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      bottom: bottom,
    );
  }
}
