import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/custom_widgets/safe_area.dart';
import '../utilities/locator.dart';
import '../controllers/bottom_nav_bar_controller.dart';
import '../utilities/constants.dart' as c;
import '../custom_widgets/get_app_fab.dart';

const List<IconData> _passiveIconList = [
  Icons.home_outlined,
  Icons.group_outlined,
  Icons.add,
  Icons.search,
  Icons.person_outline
];
const List<IconData> _activeIconList = [
  Icons.home,
  Icons.group,
  Icons.add,
  Icons.search,
  Icons.person
];

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(
            key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    locator<NavBarController>().navigationShell = navigationShell;
    return ChangeNotifierProvider.value(
      value: locator<NavBarController>(),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxHeight > constraints.maxWidth) {
              return ScaffoldWithNavigationBar(
                body:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                      width:
                          (width < c.indealAppWidth) ? width : c.indealAppWidth,
                      child: navigationShell)
                ]),
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected:
                    Provider.of<NavBarController>(context, listen: false)
                        .goBranch,
              );
            } else {
              return ScaffoldWithNavigationRail(
                body:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                      width:
                          (width < c.indealAppWidth) ? width : c.indealAppWidth,
                      child: navigationShell)
                ]),
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected:
                    Provider.of<NavBarController>(context, listen: false)
                        .goBranch,
              );
            }
          },
        );
      },
    );
  }
}

class ScaffoldWithNavigationBar extends StatelessWidget {
  const ScaffoldWithNavigationBar({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      child: Scaffold(
        floatingActionButton: getAppFabBuilder(),
        body: body,
        bottomNavigationBar:
            Provider.of<NavBarController>(context, listen: true).enabled
                ? Container(
                    height: c.navBarHeight,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      currentIndex: selectedIndex,
                      // c.navBarIconSize:
                      //     c.navBarIconSize, //TODO: idk. should these change size based on how big the device is?
                      selectedFontSize: 0.0,
                      unselectedFontSize: 0.0,
                      showUnselectedLabels: false,
                      showSelectedLabels: false,
                      unselectedItemColor:
                          Theme.of(context).colorScheme.onBackground,
                      selectedItemColor:
                          Theme.of(context).colorScheme.onBackground,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      items: [
                        for (int i = 0; i < _passiveIconList.length; i++)
                          BottomNavigationBarItem(
                              icon: Icon(
                                _passiveIconList[i],
                                size: c.navBarIconSize,
                              ),
                              activeIcon: Icon(
                                _activeIconList[i],
                                size: c.navBarIconSize + c.navBarIconSizeAdder,
                              ),
                              label: ''),
                      ],
                      onTap: (index) => onDestinationSelected(index),
                    ),
                  )
                : null,
      ),
    );
  }
}

class ScaffoldWithNavigationRail extends StatelessWidget {
  const ScaffoldWithNavigationRail({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      child: Scaffold(
        floatingActionButton: getAppFabBuilder(),
        body: Row(
          children: [
            // Fixed navigation rail on the left (start)
            if (Provider.of<NavBarController>(context, listen: true).enabled)
              NavigationRail(
                selectedLabelTextStyle: const TextStyle(fontSize: 0),
                unselectedLabelTextStyle: const TextStyle(fontSize: 0),
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: NavigationRailLabelType.none,
                destinations: [
                  for (int i = 0; i < _passiveIconList.length; i++)
                    NavigationRailDestination(
                      label: const Text(""),
                      icon: Icon(
                        _passiveIconList[i],
                        size: c.navBarIconSize,
                      ),
                      selectedIcon: Icon(
                        _activeIconList[i],
                        size: c.navBarIconSize + c.navBarIconSizeAdder,
                      ),
                    ),
                ],
              )
            else
              SizedBox(width: 80),
            //const VerticalDivider(thickness: 1, width: 1),
            // Main content on the right (end)
            Expanded(
              child: body,
            ),
          ],
        ),
      ),
    );
  }
}
