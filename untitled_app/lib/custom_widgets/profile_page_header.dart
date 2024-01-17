import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/users.dart';
import '../custom_widgets/profile_avatar.dart';
import '../controllers/bottom_nav_bar_controller.dart';
import '../utilities/locator.dart';
import '../utilities/constants.dart' as c;

class ProfileHeader extends StatelessWidget {
  final AppUser user;
  final bool loggedIn;

  const ProfileHeader({
    super.key,
    required this.user,
    this.loggedIn = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'profileImage',
                      child: IconButton(
                        onPressed: () {
                          if (loggedIn) {
                            context.pushNamed("profile_picture_detail",
                                extra: user.profilePicture);
                            locator<NavBarController>().disable();
                          }
                        },
                        icon: ProfileAvatar(
                            size: c.widthGetter(context) * 0.24,
                            url: user.profilePicture),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _ProfilePageTopNumberDisplay(
                                  number: user.followers.length,
                                  label:
                                      AppLocalizations.of(context)!.followers,
                                  onPressed: () {
                                    if (loggedIn) {
                                      context.push("/profile/followers",
                                          extra: user);
                                    }
                                  },
                                ),
                                _ProfilePageTopNumberDisplay(
                                  number: user.following.length,
                                  label:
                                      AppLocalizations.of(context)!.following,
                                  onPressed: () {
                                    if (loggedIn) {
                                      context.push("/profile/following",
                                          extra: user);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username != ""
                          ? user.name
                          : AppLocalizations.of(context)!.userNotFound,
                      //user.name,
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      user.bio,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfilePageTopNumberDisplay extends StatelessWidget {
  final int number;
  final String label;
  final VoidCallback onPressed;

  const _ProfilePageTopNumberDisplay({
    required this.number,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: NumberFormat.compact().format(number),
            style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.normal,
                fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                fontSize: 17),
            children: [
              TextSpan(
                text: "\n$label",
              )
            ],
          ),
        ),
      ),
    );
  }
}

// goFollowing(context, List<dynamic> following) async {
//   locator<NavBarController>().disable();
//   context.pop("/profile/following");
//   // Navigator.push(
//   //   context,
//   //   MaterialPageRoute(
//   //     builder: (context) => ChangeNotifierProvider(
//   //       create: (context) =>
//   //           FollowingController(context: context, following: following),
//   //       child: Following(
//   //         following: following,
//   //       ),
//   //     ),
//   //   ),
//   // );
//   locator<NavBarController>().enable();
// }

// goFollowers(context, List<dynamic> followers) async {
//   locator<NavBarController>().disable();
//   await Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => ChangeNotifierProvider(
//         create: (context) =>
//             FollowersController(context: context, followers: followers),
//         child: Followers(
//           followers: followers,
//         ),
//       ),
//     ),
//   );
//   locator<NavBarController>().enable();
// }
