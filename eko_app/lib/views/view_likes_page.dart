import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/utilities/supabase_user_map.dart';
import 'package:eko_app/widgets/common/infinite_scrolly.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';
import 'package:eko_app/widgets/users/user_card.dart';

class ViewLikesPage extends ConsumerWidget {
  final int postId;
  final bool dislikes;
  const ViewLikesPage({super.key, required this.postId, this.dislikes = false});

  Future<(List<MapEntry<String, Never?>>, bool)> getter(
    List<MapEntry<String, Never?>> list,
    WidgetRef ref,
  ) async {
    final lastUid = list.isEmpty ? null : list.last.key;
    final rows = await supabase.rpc('paginated_post_likes', params: {
      'p_limit': c.usersOnSearch,
      'p_id': postId,
      'p_last_uid': lastUid,
      'p_dislikes': dislikes,
    });

    final rowList = rows as List<dynamic>? ?? [];
    final userList = rowList.map((row) {
      final mapped = currentUserDocFromSupabaseRow(
        Map<String, dynamic>.from(row as Map),
        const [],
      );
      return UserModel.fromJson(mapped);
    }).toList();

    ref.read(userPoolProvider).putAll(userList);
    return (
      userList.map((item) => MapEntry(item.uid, null)).toList(),
      userList.length < c.usersOnSearch,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: dislikes
            ? Text(AppLocalizations.of(context)!.viewDislikes)
            : Text(AppLocalizations.of(context)!.viewLikes),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: InfiniteScrolly<String, Never?>(
        getter: (data) async {
          return await getter(data, ref);
        },
        widget: userCardBuilder,
        initialLoadingWidget: UserLoader(length: 12),
      ),
    );
  }
}
