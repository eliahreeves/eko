import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/types/activity.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/common/infinite_scrolly.dart';
import 'package:eko_app/widgets/notifications/activity_card.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';

class RecentActivity extends ConsumerWidget {
  const RecentActivity({super.key});

  Future<(List<MapEntry<ActivityModel, Never?>>, bool)> getter(
    List<MapEntry<ActivityModel, Never?>> list,
    WidgetRef ref,
  ) async {
    final params = <String, dynamic>{
      'p_limit': c.postsOnRefresh,
    };
    if (list.isNotEmpty) {
      params['p_last_time'] = list.last.key.createdAt;
      params['p_last_id'] = list.last.key.id;
    }
    final rows = await supabase.rpc('paginated_activities', params: params);

    final rowList = rows as List<dynamic>? ?? [];
    final activityList = rowList.map((row) {
      return ActivityModel.fromJson(Map<String, dynamic>.from(row as Map));
    }).toList();

    return (
      activityList.map((item) => MapEntry(item, null)).toList(),
      activityList.length < c.usersOnSearch,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop('poped'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.recentActivity,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: InfiniteScrolly<ActivityModel, Never?>(
        getter: (data) => getter(data, ref),
        widget: recentActivityCardBuilder,
        initialLoadingWidget: UserLoader(),
      ),
    );
  }
}
