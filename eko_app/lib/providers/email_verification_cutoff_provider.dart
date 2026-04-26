import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/utilities/supabase_ref.dart';

final emailVerificationCutoffProvider = FutureProvider<DateTime?>((ref) async {
  try {
    final row = await supabase
        .from('utilities')
        .select('minimum_version')
        .eq('platform', 'email_verification_cutoff')
        .maybeSingle();
    if (row == null) return null;
    final value = row['minimum_version'] as String?;
    if (value == null) return null;
    return DateTime.tryParse(value)?.toUtc();
  } catch (e, st) {
    debugPrint('Failed to load emailVerificationCutoffDate: $e\n$st');
    return null;
  }
});
