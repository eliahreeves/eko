import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/localization/generated/app_localizations_en.dart';

//import '../utilities/constants.dart' as c;
import '../controllers/settings_controller.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsController(context: context),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onBackground),
              onPressed: () => context.pop("poped"),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            title: Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          body: ListView(
            children: [
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.darkMode),
                value: Provider.of<SettingsController>(context, listen: false)
                    .getThemeValue(),
                onChanged: (value) {
                  Provider.of<SettingsController>(context, listen: false)
                      .changeValue(value);
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!
                    .newActivityNotifications), // TODO: add localization
                value: Provider.of<SettingsController>(context, listen: true)
                    .activityNotification,
                // value: Provider.of<NotificationProvider>(context, listen: true).notificationEnabled,
                onChanged: (value1) {
                  Provider.of<SettingsController>(context, listen: false)
                      .toggleActivityNotification(value1);
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              ListTile(
                  title: Text(AppLocalizations.of(context)!.blockedAccounts),
                  leading: const Icon(Icons.no_accounts_outlined),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () => Provider.of<SettingsController>(context, listen: false).blockedPressed()),
              TextButton(
                onPressed: () {
                  Provider.of<SettingsController>(context, listen: false)
                      .signOut();
                },
                child: Text(
                  AppLocalizations.of(context)!.logOut,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
              ),
              TextButton(
                onPressed: () =>
                    Provider.of<SettingsController>(context, listen: false)
                        .deleteAccount(),
                child: Text(
                  AppLocalizations.of(context)!.deleteAccount,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
