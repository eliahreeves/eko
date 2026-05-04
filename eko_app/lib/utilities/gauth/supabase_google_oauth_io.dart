import 'dart:async';
import 'dart:io';

import 'package:eko_app/utilities/constants.dart' as c;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInWithGoogleOAuth(GoTrueClient auth) async {
  if (Platform.isAndroid || Platform.isIOS) {
    final launched = await auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: c.supabaseOAuthRedirectUrl,
    );
    if (!launched) {
      throw AuthException('Could not open browser for Google sign-in.');
    }
    return;
  }

  if (!Platform.isLinux) {
    await auth.signInWithOAuth(OAuthProvider.google);
    return;
  }

  HttpServer? server;
  StreamSubscription<HttpRequest>? subscription;
  try {
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    } on SocketException {
      throw AuthException(
        'Could not start a local sign-in callback server on 127.0.0.1.',
      );
    }

    final redirectTo = 'http://127.0.0.1:${server.port}/';
    final completer = Completer<Uri>();

    subscription = server.listen((request) async {
      if (request.method != 'GET') {
        request.response.statusCode = 405;
        await request.response.close();
        return;
      }
      final uri = request.requestedUri;
      if (uri.queryParameters.containsKey('error')) {
        completer.completeError(
          AuthException(uri.queryParameters['error_description'] ??
              uri.queryParameters['error'] ??
              'OAuth error'),
        );
        return;
      }
      if (uri.queryParameters.containsKey('code')) {
        request.response.statusCode = 200;
        request.response.headers.contentType =
            ContentType('text', 'html', charset: 'utf-8');
        request.response.write(
          '<!DOCTYPE html><html><head><meta charset="utf-8">'
          '<title>eko</title>'
          '<style>body{font-family:sans-serif;display:flex;align-items:center;'
          'justify-content:center;height:100vh;margin:0;}'
          'p{color:#444;font-size:1.1rem;}</style>'
          '</head><body>'
          '<p>Sign-in complete. This window will close automatically.</p>'
          '<script>'
          'try { window.close(); } catch(e) {}'
          'setTimeout(() => {'
          '  document.querySelector("p").textContent = '
          '  "Sign-in complete! You can close this tab.";'
          '}, 100);'
          '</script>'
          '</body></html>',
        );
        await request.response.close();
        if (!completer.isCompleted) {
          completer.complete(uri);
        }
      } else {
        request.response.statusCode = 404;
        await request.response.close();
      }
    });

    final launched = await auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );
    if (!launched) {
      throw AuthException('Could not open browser for Google sign-in.');
    }

    final callbackUri = await completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () => throw AuthException(
        'Google sign-in timed out waiting for the browser redirect.',
      ),
    );

    await auth.getSessionFromUrl(callbackUri);
  } finally {
    await subscription?.cancel();
    await server?.close(force: true);
  }
}
