import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/controllers/view_likes_page_controller.dart';
import 'package:untitled_app/custom_widgets/pagination.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../custom_widgets/searched_user_card.dart';

class ViewLikesPage extends StatelessWidget {
  final String postId;
  const ViewLikesPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return ChangeNotifierProvider(
      create: (context) => ViewLikesPageController(postId: postId),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.viewLikes),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onBackground),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
          ),
          body: Padding(
            padding: EdgeInsets.all(height * 0.02),
            child: PaginationPage(
                getter:
                    Provider.of<ViewLikesPageController>(context, listen: false)
                        .getter,
                card: searchPageBuilder,
                startAfterQuery:
                    Provider.of<ViewLikesPageController>(context, listen: false)
                        .startAfterQuery),
          ),
        );
      },
    );
  }
}
