import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (currentSize(context) > ScreenSize.tablet) ...[
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(label: Text('Section A'), icon: Icon(Icons.home)),
                NavigationRailDestination(label: Text('Section B'), icon: Icon(Icons.settings)),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
          ],
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: currentSize(context) > ScreenSize.tablet
          ? null
          : BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _goBranch,
              items: const [
                BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
                BottomNavigationBarItem(label: 'Settings', icon: Icon(Icons.settings)),
              ],
              // onDestinationSelected: _goBranch,
            ),
    );
  }
}
