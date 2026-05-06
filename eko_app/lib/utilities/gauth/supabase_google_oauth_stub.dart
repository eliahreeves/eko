import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInWithGoogleOAuth(GoTrueClient auth) async {
  await auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: kIsWeb ? Uri.base.origin : null,
    queryParams: {'prompt': 'select_account'},
  );
}
