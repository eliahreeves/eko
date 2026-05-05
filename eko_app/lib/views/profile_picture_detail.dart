import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/widgets/loading/profile_picture_loading.dart';

class ProfilePictureDetail extends ConsumerWidget {
  final String uid;

  const ProfilePictureDetail({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userProvider(uid));
    final diameter = MediaQuery.sizeOf(context).shortestSide * 0.9;
    return Scaffold(
      body: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.shadow,
          ),
          child: Center(
            child: SizedBox(
              width: diameter,
              height: diameter,
              child: ClipOval(
                child: asyncUser.when(
                  data: (user) => CachedNetworkImage(
                    imageUrl: user.profilePicture,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const LoadingProfileImage(),
                    errorWidget: (context, url, error) =>
                        Image.asset('images/default.jpg', fit: BoxFit.cover),
                  ),
                  error: (_, __) => const Center(child: Text('Error')),
                  loading: () => const Center(child: LoadingProfileImage()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
