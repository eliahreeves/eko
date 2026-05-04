import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInWithGoogleOAuth(GoTrueClient auth) async {
  await auth.signInWithOAuth(OAuthProvider.google);
}
