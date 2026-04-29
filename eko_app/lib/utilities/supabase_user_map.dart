/// Maps a flat Supabase `get_user_by_id` row into the nested shape used by
/// [CurrentUserModel.fromJson] / [UserModel.fromJson].
Map<String, dynamic> currentUserDocFromSupabaseRow(
  Map<String, dynamic> row,
  List<String> blockedBy,
) {
  List<String> asStrList(Object? v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  final profileDataRaw = row['profileData'] ?? row['profile_data'];
  final Map<String, dynamic> profileData;
  if (profileDataRaw is Map) {
    profileData = Map<String, dynamic>.from(profileDataRaw);
  } else {
    profileData = {
      'profilePicture': row['profile_picture'] ?? row['profilePicture'] ?? '',
      'bio': row['bio'] ?? '',
      'followers': asStrList(row['followers']),
      'following': asStrList(row['following']),
      'likedPosts': asStrList(row['liked_posts'] ?? row['likedPosts']),
      'dislikedPosts': asStrList(row['disliked_posts'] ?? row['dislikedPosts']),
    };
  }

  return {
    'name': row['name'] ?? '',
    'username': row['username'] ?? '',
    'uid': '${row['id'] ?? row['uid'] ?? ''}',
    'isVerified': row['is_verified'] ?? row['isVerified'] ?? false,
    'isFollowing': row['is_following'] ?? row['isFollowing'] ?? false,
    'verificationUrl': row['verification_url'] ?? row['verificationUrl'],
    'share_online_status':
        row['share_online_status'] ?? row['shareOnlineStatus'] ?? true,
    'profileData': profileData,
    'blockedUsers': asStrList(row['blocked_users'] ?? row['blockedUsers']),
    'blockedBy': blockedBy,
  };
}
