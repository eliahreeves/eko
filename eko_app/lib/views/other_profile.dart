import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/widgets/errors/dialogs.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/profile_post_list_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/widgets/common/infinite_scrolly.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';
import 'package:eko_app/widgets/users/profile_header.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/users/verification_badge.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/posts/post_card.dart';
import 'package:eko_app/widgets/common/max_width_content.dart';
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';

class OtherProfile extends ConsumerStatefulWidget {
  final String username;
  final String? uid;
  const OtherProfile({super.key, required this.username, this.uid});

  @override
  ConsumerState<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends ConsumerState<OtherProfile> {
  String? _resolvedUid;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveUid();
  }

  Future<void> _resolveUid() async {
    if (widget.uid != null && widget.uid!.isNotEmpty) {
      setState(() {
        _resolvedUid = widget.uid;
      });
      return;
    }

    final me = ref.read(currentUserProvider).user;
    if (me.username == widget.username && me.uid.isNotEmpty) {
      setState(() {
        _resolvedUid = me.uid;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uid = await getUidFromUsername(widget.username);
      if (!mounted) return;
      setState(() {
        _resolvedUid = uid;
        _isLoading = false;
        if (uid == null) {
          _error = AppLocalizations.of(context)!.userNotFound;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context)!.profileResolveFailed;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserProvider).user.uid;
    final currentUsername = ref.watch(currentUserProvider).user.username;

    final bool isMyOwnProfile =
        (widget.uid != null && widget.uid == currentUserId) ||
            (widget.uid == null && widget.username == currentUsername);

    // Helper function to build the leading widget (back button)
    Widget? buildLeadingWidget(BuildContext context, bool isMyProfile) {
      if (isMyProfile) {
        return SizedBox(
          width: 20,
        ); // No back button for current user's own profile
      }
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
        onPressed: () => context.pop(),
      );
    }

    // Handle loading state while resolving UID
    if (_isLoading) {
      return AppScaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: _ProfileAppBarContent(
            leading: buildLeadingWidget(context, isMyOwnProfile),
            title: const SizedBox(),
            actions: const [],
          ),
        ),
        body: const Center(child: LoadingSpinner()),
      );
    }

    // Handle error state
    if (_error != null || _resolvedUid == null) {
      return AppScaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: _ProfileAppBarContent(
            leading: buildLeadingWidget(context, isMyOwnProfile),
            title: const SizedBox(),
            actions: const [],
          ),
        ),
        body: Center(
          child: Text(_error ?? AppLocalizations.of(context)!.userNotFound),
        ),
      );
    }

    final uid = _resolvedUid!;
    final width = c.widthGetter(context);
    final userAsync = ref.watch(userProvider(uid));
    final currentUser = ref.watch(currentUserProvider);
    final isBlockedByMe = userAsync.when(
      data: (profileUser) => currentUser.blockedUsers.contains(profileUser.uid),
      loading: () => false,
      error: (_, __) => false,
    );

    final blocksMe = userAsync.when(
      data: (profileUser) => currentUser.blockedBy.contains(profileUser.uid),
      loading: () => false,
      error: (_, __) => false,
    );
    final bool isCurrentUser = currentUser.user.uid == uid;
    final postListState = isCurrentUser
        ? ref.watch(profilePostListProvider)
        : ref.watch(otherProfilePostListProvider(uid));

    void popDialog() {
      Navigator.of(context, rootNavigator: true).pop();
    }

    void blockUser() async {
      popDialog();
      final currentUser = ref.read(currentUserProvider.notifier);
      await currentUser.blockUser(uid);
      if (context.mounted) {
        // Navigate back to feed
        context.go('/feed', extra: true);
      }
    }

    void showBlockDialog() {
      showMyDialog(
        AppLocalizations.of(context)!.blockTitle,
        AppLocalizations.of(context)!.blockBody,
        [
          AppLocalizations.of(context)!.cancel,
          AppLocalizations.of(context)!.block,
        ],
        [popDialog, blockUser],
        context,
        dismissable: true,
      );
    }

    Future<void> onRefresh() async {
      final futures = <Future<void>>[
        ref.refresh(userProvider(uid).future),
        ref.read(currentUserProvider.notifier).reload(),
      ];
      if (isCurrentUser) {
        futures.add(ref.read(profilePostListProvider.notifier).refresh());
      } else {
        futures.add(
            ref.read(otherProfilePostListProvider(uid).notifier).refresh());
      }
      await Future.wait(futures);
    }

    Future<void> loadMorePosts() async {
      if (isCurrentUser) {
        await ref.read(profilePostListProvider.notifier).getter();
      } else {
        await ref.read(otherProfilePostListProvider(uid).notifier).getter();
      }
    }

    return PopScope(
      canPop: true,
      child: AppScaffold(
        appBar: userAsync.when(
          data: (profileUser) => (isBlockedByMe || blocksMe)
              ? AppBar(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: _ProfileAppBarContent(
                    leading: buildLeadingWidget(context, isCurrentUser),
                    title: const SizedBox(),
                    actions: const [],
                  ),
                )
              : null,
          loading: () => AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: _ProfileAppBarContent(
              leading: buildLeadingWidget(context, isCurrentUser),
              title: const SizedBox(),
              actions: const [],
            ),
          ),
          error: (_, __) => AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: _ProfileAppBarContent(
              leading: buildLeadingWidget(context, isCurrentUser),
              title: const SizedBox(),
              actions: const [],
            ),
          ),
        ),
        body: userAsync.when(
          data: (profileUser) {
            if (isBlockedByMe || blocksMe) {
              return Center(
                child: SizedBox(
                  width: width * 0.7,
                  child: Text(
                    AppLocalizations.of(context)!.blockedByUserMessage,
                  ),
                ),
              );
            }
            return InfiniteScrollyCore<int>(
              getter: loadMorePosts,
              list: postListState.$1,
              isEnd: postListState.$2,
              widget: isCurrentUser
                  ? profilePostCardBuilder
                  : otherProfilePostCardBuilder,
              onRefresh: onRefresh,
              initialLoadingWidget: PostLoader(),
              header: _Header(user: profileUser, isCurrentUser: isCurrentUser),
              appBar: SliverAppBar(
                floating: true,
                pinned: false,
                scrolledUnderElevation: 0.0,
                centerTitle: false,
                leadingWidth:
                    null, //ref.read(authProvider).uid == null ? 100 : null,
                leading: null,
                backgroundColor: Theme.of(context).colorScheme.surface,
                titleSpacing: 0,
                title: _ProfileAppBarContent(
                  leading: isCurrentUser
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 20,
                          ),
                          onPressed: () => context.pop('popped'),
                        ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '@${profileUser.username}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (profileUser.isVerified) VerificationBadge(uid: uid),
                    ],
                  ),
                  actions: [
                    if (isCurrentUser)
                      InkWell(
                        onTap: () {
                          //ref.read(navBarProvider.notifier).disable();
                          context
                              .push(
                                '/users/${profileUser.username}/user_settings',
                              )
                              .then(
                                (_) =>
                                    {} /*ref.read(navBarProvider.notifier).enable()*/,
                              );
                        },
                        child: Icon(
                          Icons.settings_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 25,
                          weight: 10,
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: PopupMenuButton<void Function()>(
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                height: 25,
                                value: () => showBlockDialog(),
                                child: Text(
                                  AppLocalizations.of(context)!.block,
                                ),
                              ),
                            ];
                          },
                          onSelected: (fn) => fn(),
                          color: Theme.of(context).colorScheme.outlineVariant,
                          child: Icon(
                            Icons.more_vert,
                            size: 20,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: MaxWidthContent(
                    child: Divider(
                      color: Theme.of(context).colorScheme.outline,
                      height: c.dividerWidth,
                    ),
                  ),
                ),
              ),
            );
          },
          // getter: (time) =>
          //     locator<PostsHandling>().getSubProfilePosts(time, uid),
          loading: () => const Center(child: LoadingSpinner()),
          error: (error, stack) => Center(
            child: Text(AppLocalizations.of(context)!.profileLoadFailed),
          ),
        ),
      ),
    );
  }
}

class _ProfileAppBarContent extends StatelessWidget {
  const _ProfileAppBarContent({
    required this.leading,
    required this.title,
    required this.actions,
  });

  final Widget? leading;
  final Widget title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return MaxWidthContent(
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            SizedBox(width: 8),
            SizedBox(width: 40, child: leading ?? const SizedBox()),
            const SizedBox(width: 8),
            Expanded(child: Center(child: title)),
            const SizedBox(width: 8),
            Row(mainAxisSize: MainAxisSize.min, children: actions),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  final UserModel user;
  final bool isCurrentUser;
  const _Header({required this.user, required this.isCurrentUser});

  Future<void> _onFollowPressed(WidgetRef ref) async {
    await ref.read(userProvider(user.uid).notifier).toggleFollow();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final userState = ref.watch(userProvider(user.uid));
    final isFollowing = userState.valueOrNull?.isFollowing ?? user.isFollowing;

    return Column(
      children: [
        ProfileHeader(
          user: user,
          loggedIn: true, //authState.uid != null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: isCurrentUser
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //the username chager doesn't work on web i think could be firebase outage
                    if (!kIsWeb)
                      InkWell(
                        onTap: () {
                          //ref.read(navBarProvider.notifier).disable();
                          context
                              .push('/users/${user.username}/edit_profile')
                              .then(
                                (_) =>
                                    {} /*ref.read(navBarProvider.notifier).enable()*/,
                              );
                        },
                        child: Container(
                          width: width * 0.45,
                          height: width * 0.09,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.editProfile,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    if (!kIsWeb) SizedBox(width: width * 0.02),
                    InkWell(
                      onTap: () {
                        //ref.read(navBarProvider.notifier).disable();
                        context
                            .push('/users/${user.username}/share_profile')
                            .then(
                              (_) =>
                                  {} /*ref.read(navBarProvider.notifier).enable()*/,
                            );
                      },
                      child: Container(
                        width: width * 0.45,
                        height: width * 0.09,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.shareProfile,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: InkWell(
                    onTap: () => _onFollowPressed(ref),
                    child: Container(
                      width: width * 0.45,
                      height: width * 0.09,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: isFollowing
                            ? Theme.of(context).colorScheme.surfaceContainer
                            : Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Text(
                        isFollowing
                            ? AppLocalizations.of(context)!.following
                            : AppLocalizations.of(context)!.follow,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.outline,
          height: c.dividerWidth,
        ),
      ],
    );
  }
}
