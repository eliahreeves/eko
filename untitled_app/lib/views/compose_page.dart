import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../controllers/compose_controller.dart';
import '../custom_widgets/searched_user_card.dart';
import '../utilities/constants.dart' as c;
import 'package:cached_network_image/cached_network_image.dart';
import '../custom_widgets/profile_picture_loading.dart';
import '../models/group_handler.dart' show Group;

class ComposePage extends StatelessWidget {
  final Group? group;
  const ComposePage({super.key, this.group});

  @override
  Widget build(BuildContext context) {
    final audiance = AppLocalizations.of(context)!.public;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (context) => ComposeController(
        context: context,
        audience: (group != null) ? group!.name : audiance,
        // groupEndPoint: group,
      ),
      builder: (context, child) {
        Provider.of<ComposeController>(context, listen: false).initGroup(group);
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) =>
              Provider.of<ComposeController>(context, listen: false)
                  .onWillPop(),
          child: GestureDetector(
            onTap: () => Provider.of<ComposeController>(context, listen: false)
                .hideKeyboard(),
            child: Scaffold(
              floatingActionButton: SizedBox(
                width: 70,
                child: FloatingActionButton.large(
                  heroTag: null,
                  onPressed: () =>
                      Provider.of<ComposeController>(context, listen: false)
                          .addGifPressed(),
                  shape: const CircleBorder(),
                  child:
                      const Icon(Icons.add_photo_alternate_outlined, size: 40),
                ),
              ),
              appBar: AppBar(
                surfaceTintColor: Colors.transparent,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Provider.of<ComposeController>(context, listen: false)
                              .clearPressed(),
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.background),
                      child: Text(
                        AppLocalizations.of(context)!.clear,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Provider.of<ComposeController>(context, listen: false)
                              .postPressed(context),
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceVariant),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.postButton,
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                          ),
                          SizedBox(
                            width: width * 0.02,
                          ),
                          Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.background,
              ),
              body: IndexedStack(
                index: !Provider.of<ComposeController>(context, listen: false)
                        .isAtSymbolTyped
                    ? 0
                    : 1,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        SizedBox(height: height * 0.025),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.115,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl:
                                      locator<CurrentUser>().profilePicture,
                                  placeholder: (context, url) =>
                                      const LoadingProfileImage(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.onSecondary,
                                side: BorderSide(
                                  width:
                                      3.0, // Change this value for border thickness
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary, // Change this value for border color
                                  style: BorderStyle.solid,
                                ),
                              ),
                              onPressed: () => Provider.of<ComposeController>(
                                      context,
                                      listen: false)
                                  .audianceButtonPressed(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(Provider.of<ComposeController>(context,
                                          listen: true)
                                      .audience),
                                  const Icon(Icons.expand_more_rounded)
                                ],
                              ),
                            )
                          ],
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: height * 0.2),
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            focusNode: Provider.of<ComposeController>(context,
                                    listen: false)
                                .titleFocus,
                            onChanged: (s) {
                              Provider.of<ComposeController>(context,
                                      listen: false)
                                  .updateCountsTitle(s);
                              Provider.of<ComposeController>(context,
                                      listen: false)
                                  .checkAtSymbol(s);
                            },
                            controller: Provider.of<ComposeController>(context,
                                    listen: false)
                                .titleController,
                            maxLines: null,
                            cursorColor:
                                Theme.of(context).colorScheme.onBackground,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(height * 0.01),
                              hintText: AppLocalizations.of(context)!.postTitle,
                              hintStyle: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              border: InputBorder.none,
                              // labelText: AppLocalizations.of(context)!.postTitle,
                              // labelStyle: TextStyle(
                              //   fontSize: 18,
                              //   letterSpacing: 1,
                              //   fontWeight: FontWeight.normal,
                              //   color: Theme.of(context).colorScheme.onBackground,
                              // ),
                              // enabledBorder: OutlineInputBorder(
                              //   borderSide: BorderSide(
                              //       color:
                              //           Theme.of(context).colorScheme.outline),
                              //   borderRadius: BorderRadius.circular(10.0),
                              // ),
                              // focusedBorder: OutlineInputBorder(
                              //     borderRadius: BorderRadius.circular(10.0),
                              //     borderSide: BorderSide(
                              //         color: Theme.of(context).colorScheme.outline)),
                            ),
                          ),
                        ),
                        Consumer<ComposeController>(
                          builder: (context, composeController, _) =>
                              (composeController.showCount0 &&
                                      composeController.titleChars != 0)
                                  ? Text(
                                      "${composeController.titleChars}/${c.maxTitleChars} ${AppLocalizations.of(context)!.characters}")
                                  : Container(),
                        ),
                        Provider.of<ComposeController>(context, listen: true)
                                    .gif !=
                                null
                            ? FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(
                                          vertical: height * 0.025,
                                          horizontal: height * 0.025),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          Provider.of<ComposeController>(
                                                  context,
                                                  listen: true)
                                              .gif!
                                              .images!
                                              .fixedWidth
                                              .url,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              alignment: Alignment.center,
                                              width: 200,
                                              height: 150,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          Provider.of<ComposeController>(
                                                  context,
                                                  listen: false)
                                              .removeGifPressed(),
                                      icon: DecoratedBox(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background),
                                        child: Icon(
                                          Icons.cancel,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: height * 0.5),
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            focusNode: Provider.of<ComposeController>(context,
                                    listen: false)
                                .bodyFocus,
                            onChanged: (s) {
                              Provider.of<ComposeController>(context,
                                      listen: false)
                                  .updateCountsBody(s);
                              Provider.of<ComposeController>(context,
                                      listen: false)
                                  .checkAtSymbol(s);
                            },
                            controller: Provider.of<ComposeController>(context,
                                    listen: false)
                                .bodyController,
                            maxLines: null,
                            cursorColor:
                                Theme.of(context).colorScheme.onBackground,
                            keyboardType: TextInputType.multiline,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(height * 0.01),
                              hintText: AppLocalizations.of(context)!.addText,
                              hintStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              border: InputBorder.none,
                              // labelText: AppLocalizations.of(context)!.postBody,
                              // labelStyle: TextStyle(
                              //   fontSize: 18,
                              //   letterSpacing: 1,
                              //   fontWeight: FontWeight.normal,
                              //   color: Theme.of(context).colorScheme.onBackground,
                              // ),
                              // enabledBorder: OutlineInputBorder(
                              //   borderSide: BorderSide(
                              //       color:
                              //           Theme.of(context).colorScheme.outline),
                              //   borderRadius: BorderRadius.circular(10.0),
                              // ),
                              // focusedBorder: OutlineInputBorder(
                              //     borderRadius: BorderRadius.circular(10.0),
                              //     borderSide: BorderSide(
                              //         color: Theme.of(context).colorScheme.outline)),
                            ),
                          ),
                        ),

                        Consumer<ComposeController>(
                          builder: (context, composeController, _) =>
                              (composeController.showCount1 &&
                                      composeController.bodyChars != 0)
                                  ? Row(
                                      children: [
                                        Text(
                                            "${composeController.bodyChars}/${c.maxPostChars} ${AppLocalizations.of(context)!.characters}"),
                                        const Spacer(),
                                        if (composeController.newLines != 0)
                                          Text(
                                              "${composeController.newLines}/${c.maxPostLines} ${AppLocalizations.of(context)!.newLines}"),
                                      ],
                                    )
                                  : Container(),
                        ),
                        // SizedBox(height: height * 0.1),
                        // Provider.of<ComposeController>(context, listen: true).gif !=
                        //         null
                        //     ? Container()
                        //     : Container(
                        //         width: 80,
                        //         height: 80,
                        //         decoration: BoxDecoration(
                        //           shape: BoxShape.circle,
                        //           color:
                        //               Theme.of(context).colorScheme.primaryContainer,
                        //           //borderRadius: BorderRadius.circular(20.0),
                        //         ),
                        //         child: IconButton(
                        //           onPressed: () => Provider.of<ComposeController>(
                        //                   context,
                        //                   listen: false)
                        //               .addGifPressed(),
                        //           icon: const Icon(Icons.add),
                        //           color: Theme.of(context)
                        //               .colorScheme
                        //               .onPrimaryContainer,
                        //           iconSize: 50,
                        //         ),
                        //       ),
                        // Align(
                        //   alignment: Alignment.center,
                        //   child: Text(
                        //     "Add Gif",
                        //     style: TextStyle(
                        //         fontSize: 25,
                        //         color:
                        //             Theme.of(context).colorScheme.primaryContainer),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: Column(
                      children: [
                        TextField(
                            focusNode: Provider.of<ComposeController>(context,
                                        listen: false)
                                    .searchFocus,
                            controller: Provider.of<ComposeController>(context,
                                        listen: false)
                                    .searchController,
                            onChanged: (s) {
                              Provider.of<ComposeController>(context,
                                      listen: false)
                                  .checkAtSymbol(s);
                            },
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                            cursorColor:
                                Theme.of(context).colorScheme.onBackground,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(height * 0.01),
                              hintText: AppLocalizations.of(context)!.addText,
                              hintStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              border: InputBorder.none,
                            ),
                          ),
                        
                        Expanded(
                          child: Provider.of<ComposeController>(context,
                                      listen: true)
                                  .isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Provider.of<ComposeController>(context,
                                          listen: true)
                                      .hits
                                      .isEmpty
                                  ? Center(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .noResultsFound,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: Provider.of<ComposeController>(
                                              context,
                                              listen: true)
                                          .hits
                                          .length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return UserCard(
                                            tagSearch: true,
                                            onCardTap: (username) {
                                              Provider.of<ComposeController>(
                                                      context,
                                                      listen: false)
                                                  .updateTextField(
                                                      username,
                                                      Provider.of<ComposeController>(
                                                              context,
                                                              listen: false)
                                                          .titleController,
                                                      Provider.of<ComposeController>(
                                                              context,
                                                              listen: false)
                                                          .titleFocus);
                                              Provider.of<ComposeController>(
                                                      context,
                                                      listen: false)
                                                  .updateTextField(
                                                      username,
                                                      Provider.of<ComposeController>(
                                                              context,
                                                              listen: false)
                                                          .bodyController,
                                                      Provider.of<ComposeController>(
                                                              context,
                                                              listen: false)
                                                          .bodyFocus);
                                            },
                                            user: Provider.of<ComposeController>(
                                                    context,
                                                    listen: true)
                                                .hits[index]);
                                      },
                                    ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
