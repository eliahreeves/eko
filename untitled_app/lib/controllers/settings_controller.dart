import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/models/shared_pref_model.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../utilities/themes/dark_theme_provider.dart';
import '../controllers/bottom_nav_bar_controller.dart';
import 'package:go_router/go_router.dart';
import '../custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

class SettingsController extends ChangeNotifier {
  final BuildContext context;
  bool activityNotification = true;

  SettingsController({
    required this.context,
  }) {
    init();
  }
  init() async {
    activityNotification = await getActivityNotification();
    notifyListeners();
  }

  bool getThemeValue() {
    return Provider.of<DarkThemeProvider>(context, listen: false).darkTheme;
  }

  changeValue(value) {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    themeChange.darkTheme = value;
  }

   void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _delete() async {
    _popDialog();
    try {
      await locator<CurrentUser>().deleteAccount();
      locator<NavBarController>().enable();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        context.pushNamed("re_auth");
      }
    }
  }

  toggleActivityNotification(value) async {
    // final notification =
    //     Provider.of<NotificationProvider>(context, listen: false);
    // notification.notificationEnabled = value;
    // notifyListeners();
    // if (value) {
    //   await FirebaseHelper.subscribeToTopic('new_post');
    // } else {
    //   await FirebaseHelper.unsubscribeFromTopic('new_post');
    // }
    setActivityNotification(value);
    if (value) {
      locator<CurrentUser>().addFCM();
      activityNotification = true;
    } else {
      locator<CurrentUser>().removeFCM();
      activityNotification = false;
    }

    notifyListeners();
  }

  signOut() async {
    await locator<CurrentUser>().signOut();
    locator<NavBarController>().enable();
  }

  deleteAccount() {
    showMyDialog(
        AppLocalizations.of(context)!.deleteAcountTitle,
        AppLocalizations.of(context)!.deleteAcountBody,
        [
          AppLocalizations.of(context)!.goBack,
          AppLocalizations.of(context)!.delete
        ],
        [_popDialog, _delete],
        context);
  }
}
