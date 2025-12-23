import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:talker_flutter/talker_flutter.dart';

class Logs extends StatelessWidget {
  const Logs({super.key});

  @override
  Widget build(BuildContext context) {
    // return const LogsView();
    return TalkerScreen(
      talker: getIt<Talker>(),
    );
  }
}
