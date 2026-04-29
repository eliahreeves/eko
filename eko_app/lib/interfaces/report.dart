import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> addReport(WidgetRef ref, int id, String message) async {
  await supabase.rpc('report', params: {'p_message': message, 'p_post_id': id});
}
