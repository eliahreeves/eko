import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/widgets/common/time_stamp.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/types/activity.dart';
import 'package:eko_app/widgets/users/profile_picture.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/utilities/constants.dart' as c;

Widget recentActivityCardBuilder(ActivityModel activity) {
  return ActivityCardWidget(activity: activity);
}

class ActivityCardWidget extends ConsumerWidget {
  final ActivityModel activity;
  const ActivityCardWidget({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final l10n = AppLocalizations.of(context)!;
    final asyncUser = ref.watch(userProvider(activity.sourceUid));

    return InkWell(
      onTap: () {
        switch (activity.type) {
          case ActivityType.follow:
            context.push('/users/_?uid=${activity.sourceUid}');
            break;
          case ActivityType.comment:
          case ActivityType.postTag:
          case ActivityType.commentTag:
            final postId = activity.postId;
            if (postId != null) {
              context.push('/feed/post/$postId');
            }
            break;
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.01),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.03,
                right: width * 0.015,
              ),
              child: ProfilePicture(
                uid: activity.sourceUid,
                size: width * 0.115,
              ),
            ),
            Column(
              children: [
                SizedBox(
                  width: width * 0.8,
                  child: Text(
                    '${_username(asyncUser, l10n.someone)} ${_activityTypeText(activity.type, l10n)}',
                    softWrap: true,
                  ),
                ),
                Container(
                  width: width * 0.8,
                  alignment: Alignment.centerLeft,
                  child: TimeStamp(
                    time: activity.dateTime,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _username(AsyncValue<UserModel> asyncUser, String someone) {
  return asyncUser.when(
    data: (user) => '@${user.username}',
    error: (_, __) => someone,
    loading: () => someone,
  );
}

String _activityTypeText(ActivityType type, AppLocalizations l10n) {
  switch (type) {
    case ActivityType.follow:
      return l10n.followText;
    case ActivityType.postTag:
      return l10n.postTaggedText;
    case ActivityType.commentTag:
      return l10n.commentTaggedText;
    case ActivityType.comment:
      return l10n.commentText;
  }
}
