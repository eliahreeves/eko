import 'package:url_launcher/url_launcher.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/platform.dart' as platform;

class UriLauncher {
  static void launchCorrectStore() async {
    if (platform.isWeb) {
      await launchPlayStore();
    } else if (platform.isIOS) {
      await launchAppStore();
    } else {
      await launchPlayStore();
    }
  }

  static Future<void> launchAppStore() async {
    final Uri appStoreUrl = Uri.parse(c.appStoreURL);
    await launchUrl(appStoreUrl);
  }

  static Future<void> launchPlayStore() async {
    final Uri playStoreUrl = Uri.parse(c.playStoreURL);
    await launchUrl(playStoreUrl);
  }
}
