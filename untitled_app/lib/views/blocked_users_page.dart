import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/controllers/blocked_users_page_controller.dart';
import 'package:untitled_app/custom_widgets/pagination.dart';
import 'package:untitled_app/custom_widgets/searched_user_card.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).width;
    return ChangeNotifierProvider(
      create: (context) => BlockedUsersPageController(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onBackground),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            title: Text(
              AppLocalizations.of(context)!.blockedAccounts,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(height * 0.02),
            child: PaginationPage(
              externalData:Provider.of<BlockedUsersPageController>(context, listen: true).users ,
                getter: Provider.of<BlockedUsersPageController>(context, listen: false)
                    .userGetter,
                card: blockedPageBuilder,
                startAfterQuery:
                    Provider.of<BlockedUsersPageController>(context, listen: false)
                        .startAfterQuery, extraRefresh:
                      Provider.of<BlockedUsersPageController>(context, listen: false)
                          .onRefresh),
          ),
        );
      },
    );
  }
}
