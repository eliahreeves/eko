import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class SearchInterface {
  static Future<List<MapEntry<String, double>>> hitsQuery(
    String query, {
    double? lastSimilarity,
    String? lastUid,
    required bool excludeCurrent,
  }) async {
    final rows = await supabase.rpc(
      'search_users',
      params: {
        'p_search': query,
        'p_last_similarity': lastSimilarity,
        'p_last_uid': lastUid,
        'p_limit': c.usersOnSearch,
        'p_exclude_current_user': excludeCurrent,
      },
    );
    if (rows is! List) return [];
    return rows
        .map<MapEntry<String, double>>((item) {
          final row = Map<String, dynamic>.from(item as Map);
          final uid = (row['id'] ?? '').toString();
          final similarity = (row['similarity'] as num?)?.toDouble() ?? 0;
          return MapEntry(uid, similarity);
        })
        .where((item) => item.key.isNotEmpty)
        .toList();
  }

  static Future<(List<MapEntry<String, double>>, bool)> getter(
    List<MapEntry<String, double>> list,
    WidgetRef ref,
    String query, {
    excludeCurrent = false,
  }) async {
    final hits = await hitsQuery(
      query,
      lastSimilarity: list.isEmpty ? null : list.last.value,
      lastUid: list.isEmpty ? null : list.last.key,
      excludeCurrent: excludeCurrent,
    );
    final List<Future<UserModel>> asyncUsers = [];
    List<MapEntry<String, double>> filteredHits = [];
    if (excludeCurrent) {
      for (final obj in hits) {
        if (obj.key != ref.watch(currentUserProvider).user.uid) {
          filteredHits.add(obj);
          asyncUsers.add(ref.read(userProvider(obj.key).future));
        }
      }
    } else {
      filteredHits = hits;
      asyncUsers.addAll(
        hits.map((obj) => ref.read(userProvider(obj.key).future)),
      );
    }
    await Future.wait(asyncUsers);
    return (filteredHits, hits.length < c.usersOnSearch);
  }
}
