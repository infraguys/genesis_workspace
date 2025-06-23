import 'package:flutter/material.dart';
import 'package:genesis_workspace/app.dart';

import 'core/dependency_injection/di.dart';

class Main {
  static Future<void> startApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    configureDependencies();
    runApp(const WorkspaceApp());
  }
}
