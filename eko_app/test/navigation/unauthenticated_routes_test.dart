import 'package:eko_app/views/download_page.dart';
import 'package:eko_app/views/login.dart';
import 'package:eko_app/views/sign_up.dart';
import 'package:eko_app/views/welcome.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/navigation_harness.dart';

void main() {
  setUpAll(() async {
    await ensureNavigationTestPrefs();
  });

  testWidgets('signed-out user is redirected from /feed to /', (tester) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedOutNavigationOverrides(),
    );
    expect(currentRouterUri(container).path, '/');
  });

  testWidgets('signed-out: /signup shows SignUp', (tester) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedOutNavigationOverrides(),
    );
    goRouter(container).go('/signup');
    await pumpNavFrames(tester);
    expect(currentRouterUri(container).path, '/signup');
    expect(find.byType(SignUp), findsOneWidget);
  });

  testWidgets('signed-out: /login shows LoginPage', (tester) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedOutNavigationOverrides(),
    );
    goRouter(container).go('/login');
    await pumpNavFrames(tester);
    expect(currentRouterUri(container).path, '/login');
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('signed-out: /download shows DownloadPage', (tester) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedOutNavigationOverrides(),
    );
    goRouter(container).go('/download');
    await pumpNavFrames(tester);
    expect(currentRouterUri(container).path, '/download');
    expect(find.byType(DownloadPage), findsOneWidget);
  });

  testWidgets('signed-out: / shows WelcomePage', (tester) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedOutNavigationOverrides(),
    );
    goRouter(container).go('/');
    await pumpNavFrames(tester);
    expect(currentRouterUri(container).path, '/');
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('deep link to /feed while signed out lands on /', (tester) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedOutNavigationOverrides(),
    );
    goRouter(container).go('/feed');
    await pumpNavFrames(tester);
    expect(currentRouterUri(container).path, '/');
  });
}
