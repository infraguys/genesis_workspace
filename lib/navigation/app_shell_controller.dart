import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class AppShellController extends ChangeNotifier {
  StatefulNavigationShell? _navigationShell;

  void attach(StatefulNavigationShell navigationShell) {
    _navigationShell = navigationShell;
  }

  void detach() {
    _navigationShell = null;
  }

  void goToBranch(int branchIndex, {bool resetToInitialLocation = false}) {
    final StatefulNavigationShell? shell = _navigationShell;
    if (shell == null) return;
    shell.goBranch(branchIndex, initialLocation: resetToInitialLocation);
  }
}
