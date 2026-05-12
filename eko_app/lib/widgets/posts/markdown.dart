import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

enum MarkdownType { base, title }

Future<void> _defaultTagPressed(
  String username,
  BuildContext context,
  WidgetRef ref,
) async {
  if (ref.watch(currentUserProvider).user.username == username) {
    context.go('/profile');
  } else {
    context.push('/users/$username');
  }
}

String _format(String content) {
  final RegExp mentionRegex = RegExp(r'(@[a-z0-9_]{3,24})');
  final RegExp tickerRegex = RegExp(r'(\$[A-Z]{2,5}\b)');

  return content.replaceAllMapped(mentionRegex, (match) {
    String y = match[0]!;
    return '[$y]($y)';
  }).replaceAllMapped(tickerRegex, (match) {
    String y = match[0]!;
    return '[$y](${c.finance}${y.substring(1)}/)';
  });
}

MarkdownStyleSheet getTheme(BuildContext context, MarkdownType type) {
  final theme = MarkdownStyleSheet.fromTheme(Theme.of(context));
  final plain =
      type == MarkdownType.base ? theme.p : theme.p?.copyWith(fontSize: 16);
  MarkdownStyleSheet();
  final base = theme.copyWith(
    blockSpacing: 0.0,
    p: plain,
    h1: theme.p?.copyWith(fontSize: 16),
    h2: plain,
    h3: plain,
    h4: plain,
    h5: plain,
    h6: plain,
  );
  if (type == MarkdownType.title) {
    return base.copyWith(h1: plain);
  }
  return base;
}

class MarkdownView extends ConsumerWidget {
  final String content;
  final MarkdownType type;
  const MarkdownView(
      {super.key, required this.content, this.type = MarkdownType.base});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MarkdownBody(
        onTapLink: (_, uri, __) {
          if (uri?.startsWith('@') ?? false) {
            _defaultTagPressed(uri!.substring(1), context, ref);
          } else if (uri != null) {
            try {
              final u = Uri.parse(uri);
              launchUrl(u, mode: LaunchMode.externalApplication);
            } finally {}
          }
        },
        // disallow images for now
        imageBuilder: (_, __, ___) => SizedBox(),
        checkboxBuilder: (checked) {
          final colors = Theme.of(context).colorScheme;
          final borderColor =
              checked ? colors.onSurface : colors.onSurface.withAlpha(128);
          final fillColor = checked ? colors.onSurface : Colors.transparent;

          return Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 14, height: 14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(width: 1.6, color: borderColor),
                ),
                child: checked
                    ? Center(
                        child: Icon(
                          Icons.check,
                          size: 12,
                          color: colors.onPrimary,
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
        data: _format(content),
        styleSheet: getTheme(context, type));
  }
}
