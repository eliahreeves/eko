import 'package:eko_app/views/profile_picture_detail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/navigation_harness.dart';

void main() {
  setUpAll(() async {
    await ensureNavigationTestPrefs();
  });

  testWidgets('/profile_picture_detail/:id with user in pool', (tester) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedInNavigationOverrides(),
    );
    seedTestUser(container);

    goRouter(container).go('/profile_picture_detail/$testUid');
    await pumpNavFrames(tester);

    expect(
      currentRouterUri(container).path,
      '/profile_picture_detail/$testUid',
    );
    expect(find.byType(ProfilePictureDetail), findsOneWidget);
  });
}
