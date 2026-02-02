import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/presence_provider.dart';
import 'package:eko_app/views/invalid_session_page.dart';
import 'package:eko_app/widgets/loading_spinner.dart';

class RequireAuth extends ConsumerWidget {
  final Widget child;
  const RequireAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = ref.watch(currentUserProvider);
    final online = ref.watch(presenceProvider);
    if (auth.isLoading) {
      return const Center(child: LoadingSpinner());
    }
    if (user.user.uid.isEmpty) {
      return const Center(child: LoadingSpinner());
    }
    if (!online.valid) {
      return InvalidSessionPage();
    }
    return child;
  }
}
