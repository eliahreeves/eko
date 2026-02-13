import 'package:flutter/material.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class UserSearchBar extends StatelessWidget {
  final TextEditingController controller;
  const UserSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.onSurface,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(height * 0.01),
          prefixIcon: Padding(
            padding: EdgeInsets.all(width * 0.035),
            child: Image.asset(
              (Theme.of(context).brightness == Brightness.dark)
                  ? 'images/algolia_logo_white.png'
                  : 'images/algolia_logo_blue.png',
              width: width * 0.05,
              height: width * 0.05,
            ),
          ),
          hintText: AppLocalizations.of(context)!.search,
          filled: true,
          fillColor: Theme.of(context).colorScheme.outlineVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
        ),
        controller: controller,
        keyboardType: TextInputType.text,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
